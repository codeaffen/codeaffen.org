---
layout: post
title: phpypam 1.0.2
subtitle: phpypam 1.0.2 has been released
tags: [project, release, announcement, phpypam]
gh-repo: codeaffen/phpypam
gh-badge: [star, watch, fork, follow]
author: cmeissner
---

We are proud to announce the release of version 1.0.2 of phpypam.

This release contains a little change in exception handling on searches for non existing hosts.
We also add test cases to check the exception handling in ci/cd workflow.

Many thanks to [Mattias Amnefelt](https://github.com/mattiasa) his first time contribution helps us to cover more exceptions in a correct way.

## New

* add test cases to check PHPyPAMEntityNotFoundException

## Fixes

* fix #48 - raise PHPyPAMEntityNotFoundException if searching for non existing host

## Get it

* [pypi repository](https://pypi.org/project/phpypam/){:target="_blank"}
* [github repository](https://github.com/codeaffen/phpypam){:target="_blank"}

## Need help?

If you’ve found any issues in this release please head over to github and open a bug so we can take a look.
