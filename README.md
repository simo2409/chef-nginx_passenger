nginx_passenger Cookbook
========================
This cookbook compiles nginx with passenger, ngx_pagespeed and headers-more-nginx-module.

This cookbook assumes a lot of attributes to be defined, check `attributes/default.rb`
for a list of them.

Requirements
------------
All required tools to compile nginx and its modules.

Attributes
----------
The list of attributes is quite long, this cookbook inherits from others
attributes (check `attributes/default.rb`).

Usage
-----
#### nginx_passenger::default
Just include `nginx_passenger` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[nginx_passenger]"
  ]
}
```
and ensure to specify all required attributes.

Contributing
------------
For the moment it's better to not contribute to this cookbook until I
will finish to re-organize it.

License and Authors
-------------------
License: MIT

Authors:

Simone Dall'Angelo
