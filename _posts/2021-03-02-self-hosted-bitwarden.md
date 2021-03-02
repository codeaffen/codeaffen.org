---
layout: post
title: Bitwarden on premise
subtitle: Operate your own bitwarden infrastructure
tags: [bitwarden, password managers, docker, container]
author: cmeissner
---

## Why bitwarden?

There are dozen of password managers outside, most of them coming as SaaS. Bitwarden is available as Software as a Service too and can be used as simple as others. You simply [register](https://vault.bitwarden.com/#/register){:target="blank"} an account and can start to store and share your sensitive data from any of your devices.

### Security by design

Bitwarden uses end-to-end encrypted with AES256 bit encryption, salted hashing and PBKDF2 SHA-256 to secure your data.
It provides the full set of 2FA methods like Authenticator, Yubikey, U2F and more. There are plugins for all browsers and apps for all operating systems to access your sensitive data directly from there as well as use autofill functionallity.

### Features for the enterprise

Bitwarden provides professional features like secure sharing of your secrets over so called `organisations`, api access and last but not least the option to operate bitwarden in your own infrastructure.

## Running bitwarden at your own

The last freature is the unique selling point for me and it made me write this article. If you want to run bitwarden you only need a system running docker and some minutes of your time to download, install and run it.

### how to install bitwarden in your datacenter

The installation and oparation of your own bitwarden server is done with a single script. You only have to install `docker` and `docker-compose` if not yet done already. After that your run the following commands:

```text
# curl -s -o bitwarden.sh \
    https://raw.githubusercontent.com/bitwarden/server/master/scripts/bitwarden.sh \
    && chmod +x bitwarden.sh
# ./bitwarden.sh install
```

{: .box-note}
**Note:** If you want to run the server on a windows enviroment please refert the documentation on [github](https://github.com/bitwarden/server#windows).

The above command starts the installation process. It pulls the setup image and leads the operator through a simple interactive process to request all needed information.

{: .box-note}
**Note:** You need to request an installation id and key on [bitwarden.com/host](https://bitwarden.com/host/). Here you need to provide a valid e-mail address.

### running your own bitwarden server

After installation you can start your installation with one single command:

```text
# bitwarden.sh start
```

On the first run it pulls all needed images create directories and start all containers. If this is done you can access your vault via the URL you gave the installation assistent or via [localhost](https://localhost) if you let all answers unchanged.

## Unsing your bitwarden server

We try our test installation with the chrome extension. For that we created a fresh chrome profile, install the extension and configure it to use our server.

You need to open the settings dialog gear symbol on the upper left corner and write the url to your installation in the server field. All other field can be left blank but you can also put your url in there. Finally you need to click the save button in the upper right corner.

![Bitwarden extension settings](../../assets/img/bitwarden_ext_settings.png)

Now you can create a new account on your server and start to use is like you would use bitwarden clound.

## Drawback of self hosted bitwarden

It is great that bitwarden is open source and you can run it at your onw but I will not keep back some drawbacks from you.

* Premium Subscription - Running bitwarden server self hosted does not relieve you of necessity of a premium subscription to use premium features like FIDO U2F as a second factor of authentication.

* Database Software - Bitwarden uses MS SQL Server as its database server. This software has a relatively large memory footprint of 2GB or RAM in inital mode. MS SQL is also not really free software. There are attemps to provide PostgreSQL as an alternative database backend but currently these are not finished and useable.

* Single Instance - The above description only install a single instace and you have no failover capacity. I have not yet tested to provice HA functionallity with docker tools. It's up to you to evaluate this.

* Docker only - The installer only handle installation directly on docker and needs `docker-compose` as an hard dependency. Running Bitwarden on an existing Kubernets or Openshift cluster is not covered by the installer and you have to refactor it on your own. Possibly anybody provide a helm chart.

## Conclusion

If you like bitwarden but your policies don't allow to use a SaaS for saving sensitive data than Bitwarden is a up-to-date approach to save passwords in a secure manner without hasle with database files over cloud providers. It also provide team features like secret sharing and modern secure authentication features.

We can recommend Bitwarden without any doubt.
