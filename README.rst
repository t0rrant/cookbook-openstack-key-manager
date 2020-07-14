cookbook-openstack-key-manager
==============================

Description
===========

Chef cookbook that installs Openstack's Key Manager service Barbican

Requirements
============

- Chef 15 or higher
- Chef Workstation 0.18.3 for testing (also includes berkshelf for
   cookbook dependency resolution)

Platform
========

- centos

Cookbooks
=========

The following cookbooks are dependencies:

- 'apache2', '< 6.0'
- 'openstack-common', '~> 17.0'

Attributes
==========

Please see the extensive inline documentation in ``attributes/*.rb`` for
descriptions of all the settable attributes for this cookbook.

Note that all attributes are in the ``default['openstack']`` "namespace"

The usage of attributes to generate the ``barbican.conf`` is described in the
openstack-common cookbook.

Recipes
=======

openstack-key-manager::api
--------------------------

- Installs and configures barbican-api service

openstack-key-manager::identity_registration
--------------------------------------------

- Registers the barbican endpoints with keystone

Data Bags
=========

Documentation for Attributes for selecting data bag format can be found
in the attributes section of the `openstack-common cookbook
Repo <https://opendev.org/openstack/openstack-common>`__.

Documentation for format of these data bags can be found in the
`Openstack Chef
Repo <https://opendev.org/openstack/openstack-chef#data-bags>`__
repository.

TODO
====

- [ ] Pending changes on upstream cookbooks, see Berksfile for more info
- [ ] Add support for debian/ubuntu
- [x] Complete README.md with useful info, see other upstream cookbooks for example
- [ ] Add support for openstack-chef testing
- [ ] Review attributes
- [ ] Add spec tests
- [ ] Add memcached
- [ ] Add to openstack governance

License and Author
==================

+-----------------+--------------------------------------------------------+
| **Author**      | Manuel Torrinha (manuel.torrinha@tecnico.ulisboa.pt)   |
+-----------------+--------------------------------------------------------+

+-----------------+---------------------------------------------------+
| **Copyright**   | Copyright (c) 2020, Instituto Superior Técnico    |
+-----------------+---------------------------------------------------+

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
language governing permissions and limitations under the License.
