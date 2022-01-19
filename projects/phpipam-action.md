---
layout: page
title: phpipam-action
subtitle: Github action to setup a clean phpipam installation in github workflows
tags: [phpipam, php, ipam, github, github-action, workflow, testing, continuous-integration]
gh-repo: codeaffen/phpipam-action
gh-badge: [star, watch, fork, follow]
---

[![CI](https://github.com/codeaffen/phpipam-action/actions/workflows/main.yml/badge.svg)](https://github.com/codeaffen/phpipam-action/actions/workflows/main.yml){:target="_blank"}
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/944893481cbb43dea9335f9605c30c7e)](https://www.codacy.com/gh/codeaffen/phpipam-action/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=codeaffen/phpipam-action&amp;utm_campaign=Badge_Grade){:target="_blank"}

We develop and maintain two phpIPAM related projects ([phpypam](https://github.com/codeaffen/phpypam){:target="_blank"}, [phpipam-ansible-modules](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"}). To ensure a good code quality we test it against a phpipam installation within github workspaces.
Formaly we use [github containerized services](https://docs.github.com/en/actions/using-containerized-services){:target="_blank"} to run the tests. This approach was not perfect because we have to manage same code in multiple places. So we decided to create a github action to setup a clean phpipam installation.

## Usage

The action is hosted in a separate repository and available on [github marketplace](https://github.com/marketplace/actions/phpipam-action){:target="_blank"}. To use it you have to add the following to your github workflow:

~~~yaml
steps:
  - uses: actions/checkout@v2
  - uses: codeaffen/phpipam-action@v2
    with:
      ipam_version: "1.4x"
~~~

If the action finishes successfully you will be able to run your api tests against the phpipam installation.

~~~yaml
- name: "Test phpipam api"
  run: |
    curl -k --user Admin:ipamadmin -X POST https://localhost/api/ansible/user/
~~~

With the `ipam_version` parameter you will be able to test against different phpipam versions by using githubs build matrix feature. This is done by defining a job as follows:

~~~yaml
jobs:
  matrix_test:
    strategy:
      matrix:
        phpipam: ['1.4x','1.5x']
    steps:
      - uses: actions/checkout@v2
      - name: run phpipam-action
        uses: codeaffen/phpipam-action@v2
        with:
          ipam_version: ${{ matrix.phpipam }}
~~~

## Parameters

We provide the following parameters to configure the phpipam instance database:

* **ipam_version**: the phpipam version to install: Default: "latest"
* **ipam_database_host**: Database host phpipam connects to. Default: "database"
* **ipam_database_user**: Database user phpipam needs to authenticate. Default: "phpipam"
* **ipam_database_pass**: Database password phpipam needs to authenticate. Default: "phpipam"
* **ipam_database_name**: Database name phpipam uses. Default: "phpipam"
* **database_root_password**: Root password for the database. Default: "root"

{: .box-note}
**Note:** If you define a database host, the database (**ipam_database_name**) needs to be created or emptied  before the action can be executed.

## further resources

To get more information you can use the following sources:

* [github repository](https://github.com/codeaffen/phpipam-action){:target="_blank"}
* [github marketplace](https://github.com/marketplace/actions/phpipam-action){:target="_blank"}
