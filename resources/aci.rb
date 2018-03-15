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

property :label, String, name_attribute: true
property :distinguished_name, String, required: true
property :permit, [ TrueClass, FalseClass ], default: true
property :rights, Array, default: [ 'all' ]
# rules
property :userdn_rule, Hash
property :groupdn_rule, Hash
property :roledn_rule, Hash
property :targetattr_rule, Hash
property :ip_rule, Hash
property :dns_rule, Hash
# time spec
property :day_of_week, [ Array, String ]
property :time_of_day_start, String
property :time_of_day_end, String
# for ldap_entry
property :host, String, default: 'localhost'
property :port, Integer, default: 389
property :credentials, [ String, Hash ], default: 'default_credentials'
property :databag_name, String
property :use_tls, :kind_of =>	[TrueClass, FalseClass], default: false
