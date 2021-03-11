---
layout: page
title: ansible-hiera-data
subtitle: Collection to provide hieradata for Ansible (aka. AHD)
tags: [project, python, ansible, collection, galaxy]
gh-repo: codeaffen/ansible-hiera-data
gh-badge: [star, watch, fork, follow]
---

[![Version on Galaxy](https://img.shields.io/badge/dynamic/json?style=flat&label=galaxy&prefix=v&url=https://galaxy.ansible.com/api/v2/collections/codeaffen/hieradata/&query=latest_version.version)](https://galaxy.ansible.com/codeaffen/hieradata){:target="_blank"}
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/0372c2bb95e845ce96fa5d4cf13ca1ca)](https://www.codacy.com/gh/codeaffen/ansible-hiera-data/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=codeaffen/ansible-hiera-data&amp;utm_campaign=Badge_Grade){:target="_blank"}
[![Documentation Status](https://readthedocs.org/projects/ansible-hiera-data/badge/?version=develop)](https://ansible-hiera-data.readthedocs.io/en/develop/?badge=develop){:target="_blank"}

When we were starting to work with puppet v4 we realize the benefits of [hiera](https://forge.puppet.com/modules/puppet/hiera){:target="_blank"}. Its strenghts of merging configurations of different levels of precendence can solve so many problems of having duplicated data.
The decission of Ansible to deprecate and remove the possiblity of merging configuration hashes is also understandable because merging can create very complex scenarios.
With this collection we want to give you the decision to organise your configuration in another way.

## Installation

The collection is hosted on [galaxy](https://galaxy.ansible.com/codeaffen/hieradata){:target="_blank"}, so you can simply use `ansible-galaxy` to install it.

~~~bash
ansible-galaxy collection install codeaffen.hieradata
~~~

Alternatively you can install it from source.

~~~bash
git clone https://github.com/codeaffen/ansible-hiera-data.git
cd ansible-hiera-data
make dist
ansible-galaxy collection install codeaffen-hieradata-<version>.tar.gz
~~~

## Configuraton

### vars plugin configuration

The plugin comes with useful defaults to start to use the `hieradata` vars plugin without any configuration.

But if you need to customize the configuration you can see in
[documentation](https://ansible-hiera-data.readthedocs.io/en/develop/){:target="_blank"}
you can configure the vars plugin eigther via `ansible.cfg` parameter in section `hieradata` or via environment variables.

You have to keep in mind that the paths for `basedir` and `config` are relative to your inventory directory. Without any configuration you have to place
the basedir and config as followed.

~~~bash
.
├── ansible.cfg
├── hieradata
├── hieradata.yml
└── hosts
~~~

If you want to use a different base then `hieradata` you can override it by exporting `HIERADATA_BASE_DIR` environment variable. This directory also has to belongs to inventory dirctory.

~~~bash
.
├── ansible.cfg
└── inventory
    ├── hieradata
    │   └── customer_a
    ├── hieradata.yml
    └── hosts
~~~

In this example you need to do `export HIERADATA_BASE_DIR=hieradata/customer_a` if you want to use `hieradata/customer_a` as hiera basedir.

## further resources

To get more information you can use the following sources:

* [documentation](https://ansible-hiera-data.readthedocs.io/en/develop/){:target="_blank"}
* [github repository](https://github.com/codeaffen/ansible-hiera-data){:target="_blank"}
* [galaxy repository](https://galaxy.ansible.com/codeaffen/hieradata){:target="_blank"}
