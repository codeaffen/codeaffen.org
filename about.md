---
layout: page
title: About
subtitle: What is codeaffen and what is it good for
tags: [about, project, welcome]
---

My name is Christian Meißner and I founded codeaffen in fall of 2020 because me and my colleguages faced some missing ansible modules.
In a project we uses [phpIPAM](https://github.com/phpipam/phpipam) as one system component. As configuration management we use ansible.
To automate the configuration of phpIPAM we started to use the `url` module to talk to the API provided by phpIPAM. But to work with APIs this way is a mess.
As we don't have enough time and budget to deveolop ansible modules I decided to do it in my sparetime and on weekends.
Some week, inventigation of existing projects and many read documentations the first version of our `phpipam-ansible-modules` collection was released.

Currently we provide not only this collection. We also created a python library to get a common interface to talk with phpIPAM API. And we started to work on the next ansible collection. We want to create a collection which provides [hieradata](https://puppet.com/docs/puppet/latest/hiera.html) for ansible.

The complete list of current project is:

- [ansible-hiera-data](https://github.com/codeaffen/ansible-hiera-data)
- [phpipam-ansible-modules](https://github.com/codeaffen/phpipam-ansible-modules)
- [phpypam](https://github.com/codeaffen/phpypam)
