#
# Cookbook Name:: ldap
# Provider:: user
#
# Copyright 2014 Riot Games, Inc.
# Author:: Alan Willis <alwillis@riotgames.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

use_inline_resources

def whyrun_supported?
  true
end

action :create do

  require 'cicphash'

  @connectinfo = load_connection_info

  converge_by("Creating #{new_resource.common_name}") do

    dn = "#{new_resource.relativedn_attribute}=#{new_resource.common_name},#{new_resource.basedn}"

    attrs = CICPHash.new.merge(new_resource.attrs)
    attrs.merge!({ uid: new_resource.common_name })
    attrs[new_resource.relativedn_attribute.to_sym] = new_resource.common_name

    objclass = [ 'top', 'account' ]
    objclass.push(attrs[:objectClass]) if attrs.key?(:objectClass)
    objclass.push( 'extensibleObject' ) if new_resource.is_extensible

    if new_resource.is_person
      objclass.push( 'person', 'organizationalPerson', 'inetOrgPerson', 'inetUser' )
      attrs[:cn] = new_resource.common_name
      attrs[:sn] = new_resource.surname ? new_resource.surname : new_resource.common_name
    end

    if new_resource.is_person and new_resource.password
      require 'digest'
      require 'base64'
      salt = ( rand * 10 ** 5 ).to_s
      new_resource.password('{SSHA}' + Base64.encode64(Digest::SHA1.digest( new_resource.password + salt ) + salt ).chomp)
    end

    if new_resource.is_posix
      objclass.push( 'shadowAccount', 'posixAccount', 'posixGroup' )
      raise 'Must specify home directory' unless new_resource.home
      attrs[:homeDirectory] = new_resource.home

      ldap = Chef::Ldap.new

      if current_resource and current_resource.attributes.key?('uidnumber')
        unless new_resource.uid_number == current_resource.attributes['uid_number']
          attrs[:uidNumber] = new_resource.uid_number.to_s
        end
      else
        entries = ldap.search( @connectinfo, new_resource.basedn, '(objectClass=posixAccount)' )
        maxuid = entries.empty? ? 1000 : entries.map{ |e| e.uidnumber.max }.max.to_i + 1
        uid = new_resource.uid_number.nil? ? maxuid : new_resource.uid_number
        attrs[:uidNumber] = uid.to_s
      end

      if current_resource and current_resource.attributes.key?('gidnumber')
        unless new_resource.gid_number == current_resource.attributes['gid_number']
          attrs[:gidNumber] = new_resource.gid_number.to_s
        end
      else
        entries = ldap.search( @connectinfo, new_resource.basedn, '(objectClass=posixAccount)' )
        maxgid = entries.empty? ? 1000 : entries.map{ |e| e.gidnumber.max }.max.to_i + 1
        gid = new_resource.gid_number.nil? ? maxgid : new_resource.gid_number
        attrs[:gidNumber] = gid.to_s
      end
    end

    ldap_entry dn do
      host   new_resource.host
      port   new_resource.port
      credentials new_resource.credentials
      databag_name new_resource.databag_name
      attributes ({ objectClass: objclass }.merge(attrs))
      if new_resource.password
        seed_attributes ({ userPassword: new_resource.password })
      end
    end
  end
end

action :delete do

  @current_resource = load_current_resource

  if @current_resource
    converge_by("Removing #{@current_resource[:dn]}") do
      ldap_entry @current_resource[:dn] do
        host   new_resource.host
        port   new_resource.port
        credentials new_resource.credentials
        databag_name new_resource.databag_name
        action :delete
      end
    end
  end
end

def load_current_resource

  ldap = Chef::Ldap.new
  @connectinfo = load_connection_info
  user = ldap.search( @connectinfo, 
                      @new_resource.basedn, 
                      "(#{new_resource.relativedn_attribute}=#{new_resource.common_name})", 
                      'one' ).first
  
  if user
    @current_resource = Chef::Resource::LdapEntry.new user.dn
    
    user.attribute_names.each do |key|
      @current_resource.attributes[key.to_s] = user[key]
    end
  end
  @current_resource
end

def load_connection_info

  @connectinfo = Hash.new
  @connectinfo.class.module_eval { attr_accessor :host, :port, :credentials, :databag_name, :use_tls }
  @connectinfo.host = new_resource.host
  @connectinfo.port = new_resource.port
  @connectinfo.credentials = new_resource.credentials
  # default databag name is cookbook name
  databag_name = new_resource.databag_name.nil? ? new_resource.cookbook_name : new_resource.databag_name
  @connectinfo.databag_name = databag_name
  @connectinfo.use_tls = new_resource.use_tls
  @connectinfo
end

