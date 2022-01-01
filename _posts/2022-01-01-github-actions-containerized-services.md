---
layout: post
title: github actions - containerized services
subtitle: how to use containerized services within github workflows
tags: [github, workflow, container, services, docker, end-to-end tests, ansible, docker-compose, phpipam-ansible-modules, automated testing]
gh-repo: codeaffen/phpipam-ansible-modules
gh-badge: [star, watch, fork, follow]
author: cmeissner
---

For our [phpipam-ansible-modules](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"} we started early to test all our modules with end-to-end tests. For that we created for each module a playbook where entities are created, updated and deleted (crud). We ran theses playbooks by hand to check if the modules worked as expected. To automate this a bit we also use loops in our used shell to iterate over all the test playbooks and check the results manually.
All tests ran against an installation of phpipam on a test server managed by one of our team members.

## The problems

With this setup we had a lot of problems:

* We had to manually check the results of the playbooks.
* We used a closed phpipam installation for our tests which is not accessible for any other developer or contributor outside of our team.
* We can't use the tests for automatic testing with github workflow because we don't want to share our phpipam connection.
* If we want to use the tests for automatic testing all contributors needs to setup there own phpipam installation and provide connection settings via own github secrets.

## Part one - wrapper script

First off all we need a solution to wrap all playbook calls to a single one and we also need an option to check the overall results of all test cases automatically. With other words we want a script which let all of our test playbooks run, collect the results and finally fail or succeed depending on the results of the single playbook results. Ideally we also get a report where a single playbooks had failed with a known ansible stacktrace.

As we already used [pytest](https://pytest.org){:target="_blank"} in other projects for running tests we decided to use it for our phpipam ansible modules too. So we started to setup the repository for pytest and we also add new targets to our existing [Makefile](https://github.com/codeaffen/phpipam-ansible-modules/blob/develop/Makefile#L79-L90){:target="_blank"}.

```bash
tests
├── conftest.py
├── __init__.py
└── test_crud.py
Makefile
```

### conftest.py

Here we define fixtures which can be used in our tests, helper functions and addoptions to pytest. We also define a function to run all our test playbooks. We also collect all playbooks and save them in a list for later use.

### test_crud.py

In this script we define functions to eiter run all our test playbooks or to run a single playbook. This test functions can be called directly from pytest. The test function for running all playbooks is paramtrized by the list of playbooks created in `conftest.py`.

### Makefile - test related targets

We define a target to install all dependencies and another to create a valid `server.yml` with connections parameters to a phpipam installation.
Secondly we define a target to run all our tests and a target to run a single test playbook.

From now on we only need some few commands to setup and run our tests.

```bash
# install dependencies
make test-setup
# run a single test
make test-example_setup
# run all tests
make test-all
```

## Part two - local phpipam installation

After having a working pytest setup for running our tests more easily we go on to provide a toolchain for setting up a local phpipam installation. This will give developers and contributors a working phpipam installation to test their modules against. We decided to use [docker](https://www.docker.com){:target="_blank"} and [docker-compose](https://docs.docker.com/compose/){:target="_blank"} for this purpose as we can easily start different containers for database and phpipam and also tear them down after the tests are done.

### docker-compose.yml

```docker-compose
version: '3'
services:
  phpipam:
    image: phpipam/phpipam-www:v1.4.4
    ports:
      - "443:443"
    environment:
      IPAM_DATABASE_HOST: "database"
      IPAM_DATABASE_USER: "phpipam"
      IPAM_DATABASE_PASS: "phpipamadmin"
      IPAM_DATABASE_NAME: "phpipam"
    depends_on:
      - database
  database:
    image: mariadb:10.3.18
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: "rootpw"
      MYSQL_USER: "phpipam"
      MYSQL_PASSWORD: "phpipamadmin"
      MYSQL_DATABASE: "phpipam"
```

With this simple docker-compose file we start a phpipam container and a mariadb container. We decided to use simple default passwords for the local installation as it is only for testing purposes.

### setup\_database.sh

As there is no way to setup the database for phpipam easyly on first container startup we decided to create a shell script to do this.

```bash
#!/bin/bash

while ! nc -z ${DB_HOST:-127.0.0.1} ${DB_PORT:-3306}; do
  echo "Waiting for database connection..."
  sleep 1
done

echo "Database is up"

echo "Creating database ${DB_NAME:-phpipam}"
docker exec -ti docker_phpipam_1 sh -c 'mysql -h database -u phpipam -pphpipamadmin phpipam < /phpipam/db/SCHEMA.sql'

echo "Activating API"
mysql -u phpipam -pphpipamadmin -h ${DB_HOST:-127.0.0.1} phpipam --execute="UPDATE settings SET api=1 WHERE id=1;"

echo "Inserting API application"
mysql -u phpipam -pphpipamadmin -h ${DB_HOST:-127.0.0.1} phpipam --execute="INSERT INTO api (app_id, app_code, app_permissions, app_security, app_lock_wait) VALUES ('ansible','aAbBcCdDeEfF00112233445566778899',2,'ssl_token',0);
```

This script do exactly three things:

1. Connect to the database container and create the database.
2. Update the settings table to activate the API.
3. Insert the API application.

{: .box-note}
**Note:** Connection from one container to another is done by the service name. In our case the phpipam service connects to the mariadb container via `database` as hostname.

### Makefile - phpipam related targets

With the docker-compose configuration and the shell script we now can create a local phpipam installation with two simple commands and we can run our tests against it. To make it more easier we also add a target to our [Makefile](https://github.com/codeaffen/phpipam-ansible-modules/blob/develop/Makefile#L94-L97){:target="_blank"} to all the setup work for the local phpipam installation.

We also add `docker-compose stop` and `docker-compose rm` to our [Makefile](https://github.com/codeaffen/phpipam-ansible-modules/blob/develop/Makefile#L68-L69){:target="_blank"} `clean` target to make sure that we don't have any left over containers.

## Part three - putting all together

As we now have a working phpipam installation and a facility to run all tests we can start to put all of this together. We startet to investigate our options we can use in a github workflow as we already use this feature to release our modules. As github workflow don not support docker-compose but have a feature named [containerized services](https://docs.github.com/en/actions/using-containerized-services){:target="_blank"}. As this feature is very similar to docker-compose we don not need to create the workflow from scratch but we can adapt our docker-compose definition to this feature.

We created a services definition with the following content:

```yaml
services:
    database:
    image: mariadb:10.3.18
    ports:
        - "3306:3306"
    env:
        MYSQL_ROOT_PASSWORD: "rootpw"
        MYSQL_USER: "phpipam"
        MYSQL_PASSWORD: "phpipamadmin"
        MYSQL_DATABASE: "phpipam"
    phpipam:
    image: phpipam/phpipam-www:v1.4.4
    ports:
        - "443:443"
    env:
        IPAM_DATABASE_HOST: "database"
        IPAM_DATABASE_USER: "phpipam"
        IPAM_DATABASE_PASS: "phpipamadmin"
        IPAM_DATABASE_NAME: "phpipam"
```

With this definition we get a running database and phpipam container similar to the one we have defined in our [docker-compose.yml](https://github.com/codeaffen/phpipam-ansible-modules/blob/develop/tests/docker/docker-compose.yml){:target="_blank"}.

With that services running we can start to create some steps to define the workflow.

*checkout* - we checkout our repository and the phpipam repository with.

```yaml
- uses: actions/checkout@v2
- name: Checkout phpipam repo
  uses: actions/checkout@v2
  with:
    repository: phpipam/phpipam
    ref: v1.4.4
    path: phpipam
```

*test environemnte* - we setup a python and our test environment.

```yaml
- name: Set up Python
  uses: actions/setup-python@v2
  with:
    python-version: '3.x'
- name: setup test environment
  run: |
    make test-setup
env:
  PHPIPAM_URL: "https://localhost"
  PHPIPAM_APPID: "ansible"
  PHPIPAM_USERNAME: "admin"
  PHPIPAM_PASSWORD: "ipamadmin"
```

*setup database* - waiting for database to come up and setup the database.

```yaml
- name: "waiting for database to come online"
  run: |
    for i in `seq 1 10`;
    do
      nc -z 127.0.0.1 3306 && echo Success && exit 0
      echo -n .
      sleep 1
    done
    echo Failed waiting for MySQL && exit 1
- name: load data into database
  run: |
    mysql -h 127.0.0.1 -u phpipam -pphpipamadmin phpipam < phpipam/db/SCHEMA.sql
- name: activate api
  run: |
    mysql -h 127.0.0.1 -u phpipam -pphpipamadmin phpipam --execute="UPDATE settings SET api=1 WHERE id=1;"
- name: add api key for tests
  run: |
    mysql -h 127.0.0.1 -u phpipam -pphpipamadmin phpipam --execute="INSERT INTO api (app_id, app_code, app_permissions, app_security, app_lock_wait) VALUES ('ansible','aAbBcCdDeEfF00112233445566778899',2,'ssl_token',0);"
```

*run tests* - we run the tests.

```yaml
- name: run example setup
  run: |
    make test-example_setup
  env:
    PHPIPAM_VALIDATE_CERTS: false
- name: run playbook tests
  run: |
    make test-all
  env:
    PHPIPAM_VALIDATE_CERTS: "false"
```

With all these steps we are now ready to run our tests automatically within our github workflows. We only need to set an event on which the workflow will be triggered. We decided to use the `push` event.

## Conclusion and what to do next

Github workflows are great to use as they allow us to run our tests automatically and we can use the workflow to release our modules. We and all of our contributors have actual test results on each push to github. So they can be very sure that changes do not break our modules. They also have an option to start a local phpipam installation and run our tests against it.

Next we can start to make other workflows dependent on the ent-to-end tests e.g. the release workflow. So we automatically make sure that we only relase working modules.
Another task is to extend the workflow to run our tests against a matrix of different phpipam, python and ansible versions to extend the coverage of a wide range of different version mixtures.
