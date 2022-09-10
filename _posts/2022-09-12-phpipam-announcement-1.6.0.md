---
layout: post
title: codeaffen.phpipam v1.6.0
subtitle: phpipam ansible modules 1.6.0 has been released
tags: [project, release, announcement, pam, phpipam, phpipam-ansible-modules]
gh-repo: codeaffen/phpipam-ansible-modules
gh-badge: [star, watch, fork, follow]
author: cmeissner
---

We are proud to announce the release of version 1.6.0 of phpipam-ansible-modules.

This release contains minor changes and a few bug fixes.

## Minor Changes

- Fix #84 - Allow vlans with same vlan id in different l2 routing domains
- fix \#85 - Add `routing_domain` parameter to subnet module to allow subnet with same vlan id in different l2domains

## Bugfixes

- Fix \#77 - hostname parameter missing in task for address test case
- Fix documentation toolchain to link to external content automatically
- fix \#80 - Can't add VLAN to subnet through to phpipam implementation differences in different entities

## Get it

- [galaxy repository](https://galaxy.ansible.com/codeaffen/phpipam){:target="_blank"}
- [github repository](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"}

## Need help?

If you’ve found any issues in this release please head over to github and open a bug so we can take a look.
