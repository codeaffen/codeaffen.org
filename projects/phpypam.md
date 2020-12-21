---
layout: post
title: phpypam
subtitle: Python client library for phpIPAM API
tags: [project, phpipam, api, library, python]
---

As we started to develop phpipam-ansible-modules we used an existing python library for phpIPAM API. As we needed a good error handling and we don't expect a quick fix of existing project we started to develop our own library.

## installation

This library is hosted on [pypi.org](https://pypi.org/project/phpypam/){:target="_blank"}, so you can simply use `pip` to install it.

~~~bash
pip install phpypam
~~~

Alternatively you can install it from source. You need to do the following:

~~~bash
$ git clone https://github.com/codeaffen/phpypam.git
Cloning into 'phpypam'...
remote: Enumerating objects: 1, done.
remote: Counting objects: 100% (1/1), done.
remote: Total 366 (delta 0), reused 0 (delta 0), pack-reused 365
Receiving objects: 100% (366/366), 88.57 KiB | 521.00 KiB/s, done.
Resolving deltas: 100% (187/187), done.
$ cd phpypam/
$ python setup.py install
~~~

## quick start

To start using `phpypam` you simply have to write some lines of code.

{% highlight python linenos %}
import phpypam

pi = phpypam.api(
  url='https://ipam.example.com',
  app_id='ansible',
  username='apiuser',
  password='apiP455wd',
  ssl_verify=True
)
pi.get_entity(controller='sections')
{% endhighlight %}

## making api connection

To connect to phpIPAM API you need some parameter to authenticate against the phpIPAM instance.

| Parameter | Description | Default |
| :--------- | :----------- | :------- | |
| url | The URL to a phpIPAM instance. It includes the protocol (http or https). | |
| app_id | The app_id which is used for the API operations. |
| username | The `username` which is used to connect to API. | None |
| password | The `password` to authenticate `username` against API. | None |
| ssl_verify | Should certificate of endpoint verified or not. Useful if you use a self signed certificate. | True |

*Example* connect to api and request current token:

{% highlight python linenos %}
connection_params = dict(
    url=server['url'],
    app_id=server['app_id'],
    username=server['username'],
    password=server['password'],
    ssl_verify=True
)

pi = phpypam.api(**connection_params)

token = pi.get_token()
{% endhighlight %}

First of all you create a dictionary with the connection data. This dictionary will unpacked for creating a `phpypam.api` object.

If all went well you can use the `pi.get_token` to get the currently valid token from API.

## get available controllers

To work with the phpIPAM api it is useful to know all available controllers. To achieve this you can eighter read the api documentation or you can use the `controllers` method.

{% highlight python %}
controllers = pi.controllers()
{% endhighlight %}

The method returns a set with all supported controllers.

## get an entity

To get an entity the `get_entity` method has to be used.

~~~python
get_entity(controller, controller_path=None, params=None)
~~~

*Example* get a `section` by name:

{% highlight python linenos %}
entity = pi.get_entity(controller='sections', controller_path='foobar')
{% endhighlight %}

This call returns a dictionary for the entity with the name `foobar`.

## create an entity

To create an entity the `create_entity` method has to be used.

~~~python
create_entity(controller, controller_path=None, data=None, params=None)
~~~

*Example* create a `section` if it does not exists:

{% highlight python linenos %}
my_section = dict(
    name='foobar',
    description='new section',
    permissions='{"3":"1","2":"2"}'
)

try:
    entity = pi.get_entity(controller='sections', controller_path=my_section['name'])
except PHPyPAMEntityNotFoundException:
    print('create entity')
    entity = pi.create_entity(controller='sections', data=my_section)

{% endhighlight %}

In this example first we check if the section we work on already exists. If the PHPyPAMEntityNotFoundException is raised we create the entity.

## update an entity

To update an entity the `update_entity` method has to be used.

~~~python
update_entity(controller, controller_path=None, data=None, params=None)
~~~

*Example* update a `section` if it exists:

{% highlight python linenos %}
my_section['description'] = 'new description'

entity = pi.get_entity(controller='sections', controller_path=my_section['name'])
pi.update_entity(controller='sections', controller_path=entity['id'], data=my_section)
{% endhighlight %}

Here we change the data we want to change in the dict from the former example of creating a section. Then we get the entity to get the id of it to work on.

{: .box-note}
**Note:** All modifying operations need the id of an entity not the name.

In the last step we call `update_entity` and put the entity id in parameter `controller_path` with the `data` parameter we provide the fully entity description dictionary.

## delete an entity

To delete an entity the `delete_entity` method has to be used.

~~~python
delete_entity(controller, controller_path, params=None)
~~~

*Example* delete a existing section:

{% highlight python linenos %}
entity = pi.get_entity(controller='sections', controller_path=my_section['name'])
pi.delete_entity(controller='sections', controller_path=entity['id'])
{% endhighlight %}

In this example we request the entity we created/updated in the above examples. After that we call `delete_entity` with the entity id from the request before.

## possible exceptions

* *PHPyPAMInvalidCredentials* - will be raised if `username` or `password` is wrong.
* *PHPyPAMInvalidSyntax* - will be raised if `app_id` is wrong.
* *PHPyPAMEntityNotFoundException* - will be raised if the entity does not exists.

## further documentation

To get more information you can use the following sources:

* [documentation](https://phpypam.readthedocs.io/en/latest/index.html){:target="_blank"}
* [github repository](https://github.com/codeaffen/phpypam){:target="_blank"}
