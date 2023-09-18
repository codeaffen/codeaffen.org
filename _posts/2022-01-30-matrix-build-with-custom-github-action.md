---
layout: post
title: Build matrix in github workflows
subtitle: Run jobs in different variations
tags: [github, workflow, github-action, automated testing, build matrix, continuous-integration, docker]
author: cmeissner
redirect_from: /2022-01-30-matrix-build-with-custom-github-action/
---

In the last blog post [github actions - containerized services](https://codeaffen.org/2022-01-01-github-actions-containerized-services/) we described how to use containerized services to run tests against a fresh phpipam installation in each test run.
This is a great step forward for automated testing but we can go a step further and use matrix builds to run the tests against multiple phpipam versions.

## The build matrix feature

With the [build matrix feature](https://docs.github.com/en/actions/using-jobs/using-a-build-matrix-for-your-jobs){:target="_blank"} you are able to create a matrix for different variations of your jobs.
E.g. you can run jobs against multiple versions of your used programing languages or like in our case against different phpipam versions.

We espacially want to run our test job against head version of v1.4 and v1.5 of phpipam. To define the matrix we add the following to the test job in our github workflow definition:

{% highlight yaml %}
{% raw %}

jobs:
  test:
    strategy:
      matrix:
        phpipam: ['1.4x','1.5x']
{% endraw %}
{% endhighlight %}

The matrix values can be accessed by using the variable `{% raw %}${{ matrix.phpipam-version }}{% endraw %}`. In our case in the service container definition for the phpipam container.

{% highlight yaml %}
{% raw %}
phpipam:
  image: phpipam/phpipam-www:${{ matrix.phpipam-version }}
  ports:
    - "443:443"
{% endraw %}
{% endhighlight %}

From now for each variation of the matrix a job will be created according to your job definition in your github workflow.

## full workflow

To make the workflow more clear and readable we put some recurring data in environment variables and apply them to the container or step definitions.

The full workflow definition looks like this:

{::options parse_block_html="true" /}
<details><summary markdown="span">See the code!</summary> <!-- markdownlint-disable MD033 -->
{% highlight yaml linenos %}
{% raw %}
name: CI

on: [push]

jobs:
  test:
    name: end to end tests
    runs-on: ubuntu-latest
    env:
      DATABASE_HOST: "database"
      DATABASE_USER: "phpipam"
      DATABASE_PASS: "phpipamadmin"
      DATABASE_NAME: "phpipam"
    strategy:
      matrix:
        phpipam-version: ['1.4x', '1.5x']
    services:
      database:
        image: mariadb:10.3.18
        ports:
          - "3306:3306"
        env:
          MYSQL_ROOT_PASSWORD: "rootpw"
          MYSQL_USER: ${{ env.DATABASE_USER }}
          MYSQL_PASSWORD: ${{ env.DATABASE_PASS }}
          MYSQL_DATABASE: ${{ env.DATABASE_NAME }}
      phpipam:
        image: phpipam/phpipam-www:${{ matrix.phpipam-version }}
        ports:
          - "443:443"
        env:
          IPAM_DATABASE_HOST: ${{ env.DATABASE_HOST }}
          IPAM_DATABASE_USER: ${{ env.DATABASE_USER }}
          IPAM_DATABASE_PASS: ${{ env.DATABASE_PASS }}
          IPAM_DATABASE_NAME: ${{ env.DATABASE_NAME }}
        options: >-
          --label "phpipam-cnt"
    steps:
      - uses: actions/checkout@v2
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
      - name: "waiting for database to come online"
        run: |
          for i in `seq 1 10`;
          do
            nc -z 127.0.0.1 3306 && echo Success && exit 0
            echo -n .
            sleep 1
          done
          echo Failed waiting for MySQL && exit 1
      - name: setup phpipam
        run: |
          export PHPIPAM_CONTAINER=$(docker container list --filter=label=phpipam-cnt --format={{.Names}})
          docker exec ${PHPIPAM_CONTAINER} sh -c 'mysql -h ${{ env.DATABASE_HOST }} -u ${{ env.DATABASE_USER }} -p${{ env.DATABASE_PASS}} phpipam < phpipam/db/SCHEMA.sql'
          docker exec ${PHPIPAM_CONTAINER} sh -c 'mysql -h ${{ env.DATABASE_HOST }} -u ${{ env.DATABASE_USER }} -p${{ env.DATABASE_PASS}} phpipam --execute="UPDATE settings SET api=1 WHERE id=1;"'
          docker exec ${PHPIPAM_CONTAINER} sh -c 'mysql -h ${{ env.DATABASE_HOST }} -u ${{ env.DATABASE_USER }} -p${{ env.DATABASE_PASS}} phpipam --execute="INSERT INTO api (app_id, app_code, app_permissions, app_security, app_lock_wait) VALUES (\"ansible\",\"aAbBcCdDeEfF00112233445566778899\",2,\"ssl_token\",0);"'
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
{% endraw %}
{% endhighlight %}
</details>
{::options parse_block_html="false" /}

## conclusion and next steps

We try to make the workflow as simple as possible and increase the readability.

As already mentioned we move some parameters such as database name, user, password and host to job scoped environment variables we can reuse theses values in different places.

As we run all database related tasks inside the phpipam container we don't need to checkout phpipam repository to get the current schema. We also guarantee in that way that the database is always initialized with the schema for the current used phpipam version.

In the next iteration we will try to make the workflow more generic by moving the service setup to an custom action. We will put all of our findings and the approach we choose to develop the custom action in a new blogpost.
