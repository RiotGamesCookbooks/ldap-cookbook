# ldap Cookbook

This cookbook provides resources to manage LDAP objects

## Dependencies

Chef 11

Ruby Gems: net-ldap, cicphash

## Resources

### ldap_entry

This resource is used to manage generic LDAP entries. It makes use of the ruby net-ldap library, and can be used with any LDAP directory service.

Name | Description | Type | Default
-----|-------------|------|----------
distinguished_name | Distinguished Name (DN) | String | Name Attribute
attributes | Attributes to be set on the entry. Existing attributes of the same name will have their contents replaced | Hash
append_attributes | Attributes whose values are to be appended to any existing values, if any | Hash
seed_attributes | Attributes whose values are to be set once and not modified again | Hash
prune | List of attributes to be removed, or a Hash of attributes with specific values to be removed | Array or Hash
host | The host to connect to | String | localhost
port | The port to connect to | Integer | 389
credentials | See the 'Credentials' section below | String or Hash | 'default'
databag_name | The databag that will be used to lookup the credentials data bag item | String | The name of the calling cookbook

__ACTIONS__
* __create__
* delete

__*Other resources in this cookbook make use of this one to create objects in the directory server. This means that they also require the 'host', 'port', 'credentials' and 'databag_name' parameters which are simply passed through to this resource. Omitting these common parameters from the resource descriptions below for brevity*__

### ldap_user

Creates a user for various kinds of identity management purposes. This is useful to create users who can bind (connect) and use the LDAP instance. It can also be used to create users with posix attributes on them for use with UNIX systems.

Name | Description | Type | Default
-----|-------------|------|----------
common_name | Value to be set as both uid and cn attributes. See relativedn_attribute | String  | Name Attribute
surname | The surname of the user. Should be set on accounts that will be used by people | String | Matches the value of common_name
password | Optional password should be specified in plaintext. Will be converted to a salted sha (SSHA) hash before being sent to the directory | String
home | home directory. Required for posix accounts | String
shell | login shell. Required for posix accounts | String
basedn | The DN that will be the parent of the user account entry ( e.g. 'ou=people,... ). Required | String
relativedn_attribute | The relative distinguished name (RDN) attribute. This is will be used to name the common_name attribute from above. Given a common_name of 'bjensen' and a basedn attribute of 'ou=people,o=myorg,c=US' the distinguished name would be 'uid=bjensen,ou=people,o=myorg,c=US' | 'uid'
uid_number | Required for posix accounts. If not supplied, the basedn will be searched for the highest value and the next increment will be used | Integer | 1000
gid_number | Required for posix accounts. If not supplied, the basedn will be searched for the highest value and the next increment will be used | Integer | 1000
is_person | Will this be used by a person? | Boolean | true
is_posix | Will this be used on a posix system? | Boolean | true
is_extensible | Can the entry be extended using custom attributes? | Boolean | false
attrs | additional attributes to be added to the account | Hash | 

__ACTIONS__
* __create__
* delete

### Credentials

The 'credentials' attribute found on the resources above provides a way to use credentials stored in a databag. It can either be a Hash object with the keys defined below, or a String. If this specified a String, it will look for a databag whose name matches the calling cookbook and pull out an item whose name matches the 'credentials' string. This data bag item should have the Hash keys described below. If no credentials are specified, it will look for a data bag item called 'default_credentials'.

key      | value | example
---------|-------|--------
bind_dn   | The bind DN used to initialize the instance and create the initial set of LDAP entries | 'cn=Directory Manager' |
password | The password, in plain text | 'Super Cool Passwords Are Super Cool!!!!!'

## Usage

The default recipe will ensure that the necessary gems are installed for chef


```
include_recipe "ldap"

ldap_entry "ou=people,o=myorg" do
  attributes ({ objectClass: [ 'top', 'organizationalUnit'],
                ou: 'people',
                description: 'The people in my organization' })
end

ldap_user "myself" do
  basedn "ou=people,o=myorg"
  home "/home/myself"
  shell "/bin/bash"
  password "Super Cool!"
end

```

Authors
-------
Authors: Alan Willis <alwillis@riotgames.com>


License
-------
See LICENSE file
