---
layout: post
title: p3exporter 1.1.0
subtitle: p3exporter 1.1.0 has been released
tags: [project, release, announcement, phpypam]
gh-repo: codeaffen/p3exporter
gh-badge: [star, watch, fork, follow]
author: cmeissner
redirect_from: /2021-03-30-p3exporter-announcement-1.1.0/
---

We are proud to announce the release of version 1.1.0 of p3exporter.

We have continued to work on standardization for new collectors. For that purpose we introduced the `CollectorBase` class.
We also add a first version of decorator to use least recently used caches in collectors.

To reduce the size of the docker image we switched to vanilla `alpine:3` as base image.

## New

* introduce `CollectorBase` class to derive new collectors from
* added cache module with timed lru cache
* add netdev collector for network information and statistics

## Changes

* reduce docker image size
* we switched base image from python:3-slim to alpine

## Get it

* [pypi repository](https://pypi.org/project/p3exporter/){:target="_blank"}
* [dockerhub repository](https://hub.docker.com/r/codeaffen/p3exporter){:target="_blank"}
* [github repository](https://github.com/codeaffen/p3exporter){:target="_blank"}

## Need help?

If you’ve found any issues in this release please head over to github and open a bug so we can take a look.
