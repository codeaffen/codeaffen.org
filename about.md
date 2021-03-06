---
layout: page
title: About
subtitle: What is codeaffen and what is it good for
tags: [about, project, welcome]
---

My name is Christian Meißner and I founded codeaffen in fall of 2020 because my colleguages and me faced some missing ansible modules.
In a project we used [phpIPAM](https://github.com/phpipam/phpipam){:target="_blank"} as one system component. As configuration management we used ansible.
To automate the configuration of phpIPAM we started to use the `url` module to talk to the API provided by phpIPAM. But to work with APIs this way is a mess.
As we don't have enough time and budget to deveolop ansible modules I decided to do it in my sparetime and on weekends.
Some week, inventigation of existing projects and many read documentations the first version of our [phpipam-ansible-modules](https://galaxy.ansible.com/codeaffen/phpipam){:target="_blank"} collection was released.

Currently we provide not only this collection. We also created a python library to get a common interface to talk with phpIPAM API. And we started to work on the next ansible collection. We want to create a collection which provides [hieradata](https://puppet.com/docs/puppet/latest/hiera.html){:target="_blank"} for ansible.

The complete list of current projects:

- [ansible-hiera-data](https://github.com/codeaffen/ansible-hiera-data){:target="_blank"}
- [phpipam-ansible-modules](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"}
- [phpypam](https://github.com/codeaffen/phpypam){:target="_blank"}
- [p3exporter](https://codeaffen.org/projects/p3exporter/){:target="_blank"}

## What else

With this homepage we want to create a starting point to provide information about our projects, new versions and bugs.

On the other hand we want to use this blog to spot interesting topics we already encoutered in our daily work.

### Contributing

As you want to contribute a topic feel free to fork this project and create a PR. If we think your topic can be interesting for the audience we will merge an publish it.
