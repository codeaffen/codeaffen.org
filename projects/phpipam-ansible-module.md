---
layout: post
title: phpipam-ansible-modules
subtitle: Ansible Modules to manage phpIPAM installations (aka. PAM)
tags: [project, phpipam, api, python, ansible, modules, collection, galaxy]
---

We started to use phpIPAM in a customer project to use it as IP management system for the whole automation. Reasons to choose were

* provide a rice set an ipam functionality
* can be connected to foreman as an external ipam
* provide a API to manage entities

We quickly realize that there were no ready to use ansible modules. So We have started to use the API in conjunction of the ansible module "url". But this was a mess because we have to implement the whole logic of CRUD operations in complex ansible tasks.
So @cmeissner begun to develop an ansible collection with modules for most of the entities managable by API.

## installation

The collection is hosted on [galaxy](https://galaxy.ansible.com/codeaffen/phpipme){:target="_blank"}, so you can simply use `ansible-galaxy` to install it.

~~~bash
ansible-galaxy collection install codeaffen.phpipam
~~~

Alternatively you can install it from source. You need to do the following:

~~~bash
$ git clone https://github.com/codeaffen/phpipam-ansible-modules.git
Cloning into 'phpipam-ansible-modules'...
remote: Enumerating objects: 6, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 598 (delta 1), reused 4 (delta 0), pack-reused 592
Receiving objects: 100% (598/598), 130.14 KiB | 757.00 KiB/s, done.
Resolving deltas: 100% (324/324), done.
$ cd phpipam-ansible-modules
$ make dist
$ ansible-galaxy collection install -p build/collections codeaffen-phpipam-1.3.1.tar.gz
~~~

## concept of names

{: .box-note}
**Note:** Relations between entities are managed via its entities ids in phpIPAM. These entities ids are not shown in UI so it's difficult to get these ids.

To make the use of our modules as comfortable as possible we decided to implement an auto resolv mechanism to translate entities names to its entities ids.
The

## connection parameters

To connect to the phpIPAM api via ansible you have to provide at least the parameters mentioned in the table below.

| Parameter | Description | Default |
| :--------- | :----------- |:------- |
| server_url | URL of the phpIPAM server | |
| username | Username to access phpIPAM server | |
| password | Password of the user to access phpIPAM server | |
| app_id | API app name | ansible |

As `app_id` has a default it's not absolutly nessecary but good to know what is the default. This app_id has to be created before running ansible against phpIPAM API to prevent any errors.

## implicite actions

As described in [concept of names](#concept-of-names) this feature runs automatically or implicit. Another action which runs implicit is the API connection. If you define a task to create a phpIPAM entity you also define the connection parameters. If the tasks runs it creates a api connection and after that it lets magic happens.

## a simple example

As ansible to most of the CRUD stuff under the hood we don't show how to do each step separately. We want to show a simple example of managing a subnet. This example is part of our CRUD tests.
The directory structure for the test looks should look like this:

~~~bash
tests/
├── inventory
│   └── hosts
└── test_playbooks
    ├── subnet.yml
    ├── tasks
    │   ├── subnet.yml
    └── vars
        ├── server.yml
        └── subnet.yml
~~~

### the task

{% highlight yaml linenos %}
---
- name: "Ensure state of subnet: {{ name }}"
  subnet:
    server_url: "{{ phpipam_server_url }}"
    app_id: "{{ phpipam_app_id }}"
    username: "{{ phpipam_username }}"
    password: "{{ phpipam_password }}"
    cidr: "{{ subnet.cidr | default(omit) }}"
    subnet: "{{ subnet.subnet | default(omit) }}"
    mask: "{{ subnet.mask | default(omit) }}"
    description: "{{ subnet.description | default(omit) }}"
    section: "{{ subnet.section | default(omit) }}"
    linked_subnet: "{{ subnet.linked_subnet | default(omit) }}"
    vlan_id: "{{ subnet.vlan_id | default(omit) }}"
    vrf_id: "{{ subnet.vrf_id | default(omit) }}"
    master_subnet.cidr: "{{ subnet.master_subnet.cidr | default(omit) }}"
    nameserver: "{{ subnet.nameserver | default(omit) }}"
    show_as_name: "{{ subnet.show_as_name | default(omit) }}"
    permissions: "{{ subnet.permissions | default(omit) }}"
    dns_recursive: "{{ subnet.dns_recursive | default(omit) }}"
    dns_records: "{{ subnet.dns_records | default(omit) }}"
    allow_requests: "{{ subnet.allow_requests | default(omit) }}"
    scan_agent: "{{ subnet.scan_agent | default(omit) }}"
    ping_subnet: "{{ subnet.ping_subnet | default(omit) }}"
    discover_subnet: "{{ subnet.discover_subnet | default(omit) }}"
    is_folder: "{{ subnet.is_folder | default(omit) }}"
    is_full: "{{ subnet.is_full | default(omit) }}"
    subnet.state: "{{ subnet.subnet.state | default(omit) }}"
    threshold: "{{ subnet.threshold | default(omit) }}"
    location: "{{ subnet.location | default(omit) }}"
    state: "{{ subnet.state | default('present') }}"
{% endhighlight %}

As you can see all parameters will be filled from variables. Most of the parameters will be omitted if they are undefined or empty.

### the vars

To let provide some data to [the task](#the-task) you can put your test data in a variable files like that.

*subnet.yml*
{% highlight yaml linenos %}
---
base_subnet_data:
  cidr: 10.0.0.0/24
  section: "Customers"
{% endhighlight %}

If you define your own data you have to guarantee that the `section` you put in here already exists.

*server.yml*
{% highlight yaml linenos %}
---
phpipam_server_url: "https://ipam.example.com"
phpipam_app_id: ansible
phpipam_username: test
phpipam_password: "test123"
{% endhighlight %}

### the play

After you had created [the task](#the-task) and [the vars](#the-vars) file you can put all together in a playbook like this:

{% highlight yaml linenos %}
---
- hosts: localhost
  collections:
    - codeaffen.phpipam
  gather_facts: false
  vars_files:
    - vars/server.yml
    - vars/subnet.yml
  tasks:
    - name: create subnet
      include: tasks/subnet.yml
      vars:
        name: create subnet
        subnet: "{{ base_subnet_data }}"

    - name: create subnet again, no change
      include: tasks/subnet.yml
      vars:
        name: create subnet again, no change
        subnet: "{{ base_subnet_data }}"

    - name: delete subnet
      include: tasks/subnet.yml
      vars:
        name: delete subnet
        override:
          state: absent
        subnet: "{{ base_subnet_data | combine(override) }}"
{% endhighlight %}

What does this playbook do?

1. it sets the collection namespace to `codeaffen.phpipam` to use simply the module name without writing the fully qualified module name.
2. it loads server.yml and subnet.yml. There are the variables for the tasks defined.
3. it creates a subnet.
4. it run the create block again. Here should nothing be changed
5. it updates data of the subnet.
6. it deletes the test subnet.

If you run this playbook the recap should look like this:

~~~bash
$ ansible-playbook --inventory tests/inventory/hosts tests/test_playbooks/subnet.yml

PLAY [localhost] ************************************************************************************************************************************

TASK [Ensure state of subnet: create subnet] ********************************************************************************************************
changed: [localhost]

TASK [Ensure state of subnet: create subnet again, no change] ***************************************************************************************
ok: [localhost]

TASK [Ensure state of subnet: delete subnet] ********************************************************************************************************
changed: [localhost]

PLAY RECAP ******************************************************************************************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

## further resources

To get more information you can use the following sources:

* [documentation](https://phpipam-ansible-modules.readthedocs.io/en/develop/){:target="_blank"}
* [github repository](https://github.com/codeaffen/phpipam-ansible-modules){:target="_blank"}
* [galaxy repository](https://galaxy.ansible.com/codeaffen/phpipam){:target="_blank"}
