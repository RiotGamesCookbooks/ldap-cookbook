#
# Cookbook Name:: ldap
# Resource:: user
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

actions :create, :delete
default_action :create

property :common_name, String, name_attribute: true
property :surname, String
property :password, String, sensitive: true
property :home, String
property :shell, String
property :basedn, String, required: true
property :relativedn_attribute, String, default: 'uid'
property :uid_number, Integer
property :gid_number, Integer
property :is_person, [ TrueClass, FalseClass ], default: true
property :is_posix, [ TrueClass, FalseClass ], default: true
property :is_extensible, [ TrueClass, FalseClass ], default: false
property :attrs, Hash
property :host, String, default: 'localhost'
property :port, Integer, default: 389
property :credentials, [ String, Hash ], default: 'default_credentials'
property :databag_name, String
property :use_tls, [TrueClass, FalseClass], default: false
