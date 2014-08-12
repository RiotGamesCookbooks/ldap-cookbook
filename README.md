ldap Cookbook
=============
This cookbook provides resources to manage LDAP objects

Requirements
------------
Chef 11
Ruby Gems: net-ldap, cicphash
An ldap server of some kind :)

e.g.
#### packages
- `toaster` - ldap needs toaster to brown your bagel.

Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### ldap::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['ldap']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----

#### ldap::default


```
include_recipe "ldap"
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

Authors
-------
Authors: Alan Willis <alwillis@riotgames.com>


License
-------
See LICENSE file
