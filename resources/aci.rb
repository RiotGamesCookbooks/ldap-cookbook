#
# Cookbook Name:: ldap
# Resource:: aci
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

actions :set, :extend, :rescind, :unset
default_action :set

attribute :label, :kind_of => String, :name_attribute => true
attribute :distinguished_name, :kind_of => String, :required => true
attribute :permit, :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :rights, :kind_of => Array, :default => [ 'all' ]
# rules
attribute :userdn_rule, :kind_of => Hash
attribute :groupdn_rule, :kind_of => Hash
attribute :roledn_rule, :kind_of => Hash
attribute :targetattr_rule, :kind_of => Hash
attribute :ip_rule, :kind_of => Hash
attribute :dns_rule, :kind_of => Hash
# time spec
attribute :day_of_week, :kind_of => [ Array, String ]
attribute :time_of_day_start, :kind_of => String
attribute :time_of_day_end, :kind_of => String
# for ldap_entry
attribute :host, :kind_of => String, :default => 'localhost'
attribute :port, :kind_of => Integer, :default => 389
attribute :credentials, :kind_of => [ String, Hash ], :default => 'default_credentials'
attribute :databag_name, :kind_of => String
