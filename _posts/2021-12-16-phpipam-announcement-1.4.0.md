---
layout: post
title: phpipam ansible modules 1.4.0
subtitle: phpipam ansible modules 1.4.0 has been released
tags: [project, release, announcement, pam, phpipam, phpipam-ansible-modules]
gh-repo: codeaffen/phpipam-ansible-modules
gh-badge: [star, watch, fork, follow]
author: cmeissner
last-updated: 2021-12-16
---

We are proud to announce the release of version 1.4.0 of phpipam-ansible-modules.

This release contains two new modules and a few bug fixes.

## Minor Changes

- Minor formatting and spelling fixes.
- Switch sphinx from recommonmark to myst_parser.

## Bugfixes

- fix \#57 - tag lookups failed when specified in an `address` task
- fix \#61 - Device type examples
- with [AHH538](https://issues.redhat.com/browse/AAH-538){:target="_blank"} `requires_ansible` is mandatory in `meta/runtime.yml`. So we add the minimum version for our collection here.

## New Modules

- codeaffen.phpipam.location - Manage locations
- codeaffen.phpipam.tag - Manage tags

## Get it

- [galaxy repository](https://galaxy.ansible.com/codeaffen/phpipam){:target="_blank"}
- [github repository](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"}

## Need help?

If you’ve found any issues in this release please head over to github and open a bug so we can take a look.
