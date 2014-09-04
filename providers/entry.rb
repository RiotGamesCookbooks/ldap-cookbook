#
# Cookbook Name:: ldap
# Provider:: entry
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

def whyrun_supported?
  true
end

action :create do

  require 'cicphash'

  @current_resource = load_current_resource

  # LDAP instances are not case sensitive
  @new_resource.attributes.keys.each do |k|
    @new_resource.attributes[k.downcase.to_s] = @new_resource.attributes.delete(k)
  end

  converge_by("Entry #{@new_resource.distinguished_name}") do

    ldap = Chef::Ldap.new
    @connectinfo = load_connection_info

    new_attributes = CICPHash.new.merge(@new_resource.attributes.to_hash)
    seed_attributes = CICPHash.new.merge(@new_resource.seed_attributes.to_hash)
    append_attributes = CICPHash.new.merge(@new_resource.append_attributes.to_hash)

    if @current_resource.nil?
      Chef::Log.info("Adding #{@new_resource.distinguished_name}")
      new_attributes.merge!(seed_attributes)
      new_attributes.merge!(append_attributes)
      ldap.add_entry(@connectinfo, @new_resource.distinguished_name, new_attributes)
      new_resource.updated_by_last_action(true)
    else

      seed_attribute_names = seed_attributes.keys.map{ |k| k.downcase.to_s }
      current_attribute_names = @current_resource.attribute_names.map{ |k| k.downcase.to_s }

      # Include seed attributes in with the normal attributes as long as they don't already exist
      ( seed_attribute_names - current_attribute_names ).each do |attr|
        value = seed_attributes[attr].is_a?(String) ? [ seed_attributes[attr] ] : seed_attributes[attr]
        new_attributes.merge!({ attr => value })
      end

      all_attributes = new_attributes.merge(append_attributes)
      all_attribute_names = all_attributes.keys.map{ |k| k.downcase.to_s }

      # Add keys that are missing
      add_keys = Array.new

      ( all_attribute_names - current_attribute_names ).each do |attr|
        add_values = attr.is_a?(String) ? [ all_attributes[attr] ] : all_attributes[attr]
        add_keys.push([ :add, attr, add_values ])
      end

      # Update existing keys, append values if necessary
      update_keys = Array.new

      ( all_attribute_names & current_attribute_names ).each do |attr|

        # Ignore Distinguished Name (DN) and the Relative DN. 
        # These should only be modified upon entry creation to avoid schema violations
        relative_distinguished_name = @new_resource.distinguished_name.split('=').first

        next if attr =~ /DN/i || attr == relative_distinguished_name 

        if append_attributes[attr]

          append_values = append_attributes[attr].is_a?(String) ? [ append_attributes[attr] ] : append_attributes[attr]
          append_values -= @current_resource.send(attr)

          if append_values.size > 0 
            update_keys.push([ :add, attr, append_values ])
          end
        end

        if new_attributes[attr]

          replace_values = new_attributes[attr].is_a?(String) ? [ new_attributes[attr] ] : new_attributes[attr]
          if ( replace_values.size > 0 ) and ( replace_values.sort != @current_resource.send(attr).sort )
            update_keys.push([ :replace, attr, replace_values ])
          end
        end
      end

      # Prune unwanted attributes and/or values
      prune_keys = Array.new

      if @new_resource.prune.is_a?(Array)
        @new_resource.prune.each do |attr|
          next unless @current_resource.respond_to?(attr)
          prune_keys.push([ :delete, attr, nil ])
        end
      elsif @new_resource.prune.is_a?(Hash)
        @new_resource.prune.each do |attr, values|
          next unless @current_resource.respond_to?(attr)
          values = values.is_a?(String) ? [ values ] : values
          values = ( values & @current_resource.send(attr) )
          prune_keys.push([ :delete, attr, values ]) if values.size > 0
        end
      end

      # Modify entry if there are any changes to be made
      if ( add_keys | update_keys | prune_keys ).size > 0
        # Submit one set of operations at a time, easier to debug

        if add_keys.size > 0
          Chef::Log.info("Add #{@new_resource.distinguished_name} #{ add_keys }")
          ldap.modify_entry(@connectinfo, @new_resource.distinguished_name, add_keys)
        end

        if update_keys.size > 0
          Chef::Log.info("Update #{@new_resource.distinguished_name} #{update_keys}")
          ldap.modify_entry(@connectinfo, @new_resource.distinguished_name, update_keys)
        end

        if prune_keys.size > 0
          Chef::Log.info("Delete #{@new_resource.distinguished_name} #{prune_keys}")
          ldap.modify_entry(@connectinfo, @new_resource.distinguished_name, prune_keys)
        end

        new_resource.updated_by_last_action(true)
      end
    end
  end
end

action :delete do

  @current_resource = load_current_resource

  if @current_resource
    converge_by("Removing #{@current_resource.dn}") do
      ldap = Chef::Ldap.new
      @connectinfo = load_connection_info
      ldap.delete_entry(@connectinfo, @current_resource.dn)
    end
  end
end

def load_current_resource

  ldap = Chef::Ldap.new
  @connectinfo = load_connection_info
  @current_resource = ldap.get_entry(@connectinfo, @new_resource.distinguished_name)
  @current_resource
end

def load_connection_info

  @connectinfo = Hash.new
  @connectinfo.class.module_eval { attr_accessor :host, :port, :credentials, :databag_name }
  @connectinfo.host = new_resource.host
  @connectinfo.port = new_resource.port
  @connectinfo.credentials = new_resource.credentials
  # default databag name is cookbook name
  databag_name = new_resource.databag_name.nil? ? new_resource.cookbook_name : new_resource.databag_name
  @connectinfo.databag_name = databag_name
  @connectinfo
end
