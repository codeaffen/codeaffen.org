---
redirect_from: /2023-09-03-phpipam-announcement-1.7.0/
layout: post
title: codeaffen.phpipam v1.7.0
subtitle: phpipam ansible modules 1.7.0 has been released
tags: [project, release, announcement, pam, phpipam, phpipam-ansible-modules]
gh-repo: codeaffen/phpipam-ansible-modules
gh-badge: [star, watch, fork, follow]
author: cmeissner
---

We are proud to announce the release of version 1.7.0 of phpipam-ansible-modules.

This release contains one new module, a bugfix and a few enhencements.
We also add some new tests to improve the test coverage.

## Bugfixes

- Fix \#98 - fix show_supernets_only parameter

## Enhancements

- Add `folder` module to manage folders and nested folders
- Refactor `subnet` module to handle subnets in folders

## New Modules

- codeaffen.phpipam.folders - Manage folders

## Get it

- [galaxy repository](https://galaxy.ansible.com/codeaffen/phpipam){:target="_blank"}
- [github repository](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"}

## Need help?

If you’ve found any issues in this release please head over to github and open a bug so we can take a look.
