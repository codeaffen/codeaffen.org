---
layout: post
title: hieradata 0.1.0
subtitle: ansible hieradata 0.1.0 has been released
tags: [project, release, announcement, hieradata]
gh-repo: codeaffen/ansible-hiera-data
gh-badge: [star, watch, fork, follow]
author: cmeissner
last-updated: 2021-01-05
---

We are proud to announce the release of version 0.1.0 of our new ansible collection.

The `ansible-hiera-data` project was established to provide a puppet like organisation of configuration data.

{: .box-warning}
**Warning:** This version is marked as pre-release. Do not use it for productive systems.

## Minor Changes

- Add a wrapper function `combine_vars` to be compatible to default ansible.
- Add configuration parameters to manage hash and list behavior.
- Add method to parse configuration file (e.g. hieradata.yml).
- After loading, the vars will be combined with ansible functions.
- Change parameter names. Remove prefix to make documentation more clear.
- If last part is directory it can have no, one or multiple files in it.
- Last part of hierarchy can be file or directory.
- Load files from hierarchy.
- Parse entity name into hiera_vars dict.
- The hiera_vars dict can be used to generate a dynamic hierarchy.
- These function tages two extra parameters `hash_behavior` and `list_behavior` to configure this feature as needed.

## Get it

- [galaxy repository](https://galaxy.ansible.com/codeaffen/phpipam){:target="_blank"}
- [github repository](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"}

## Need help?

If you’ve found any issues in this release please head over to github and open a bug so we can take a look.
