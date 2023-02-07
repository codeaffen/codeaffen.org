---
layout: post
title: codeaffen.phpipam v1.6.1
subtitle: phpipam ansible modules 1.6.1 has been released
tags: [project, release, announcement, pam, phpipam, phpipam-ansible-modules]
gh-repo: codeaffen/phpipam-ansible-modules
gh-badge: [star, watch, fork, follow]
author: cmeissner
---

We are proud to announce the release of version 1.6.1 of phpipam-ansible-modules.

This release contains a few bug fixes and some enhancements in our test suite. We started to test our collection agains the main versions of phpIPAM. We also switch to newer github actions as the current used will be deprecated soon.

## Bugfixes

- fix \#90 - booleans in subnet module aren't working
- fix \#93 - trouble creating subnet with a vrf

## Enhancements

- Enhance test suite by running test agains main phpipam versions as matrix build
- Update test playbooks to meet best practices for ansible 2.10.x
- move to nodejs 16 for `checkout` and `setup-python` action

## Get it

- [galaxy repository](https://galaxy.ansible.com/codeaffen/phpipam){:target="_blank"}
- [github repository](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"}

## Need help?

If you’ve found any issues in this release please head over to github and open a bug so we can take a look.
