---
layout: post
title: Certificate handling with ACME
subtitle: Using ACME to automatically issue certificates from Let's Encrypt
tags: [acme, ssl, certificate, wildcard, letsencrypt, dns-server, tls-certificate, acme-challenge, acme-dns]
author: cmeissner
---

 Certificates are utilized for a multitude of purposes, the most significant of which is the authentication of domain names.  As a result, certification authorities (CAs) on the web are regarded as reliable entities to ensure that an applicant for a certificate is authentically representing the domain names in the certificate. This verification is carried out through a collection of ad hoc mechanisms.  ACME is a protocol that can be utilized by both a certificate authority and an applicant to streamline the process of verification and certificate issuance.  Other certificate management functions, such as certificate revocation, are provided by the protocol.

 Let's Encrypt is a popular free, automated and open Certificate Authority (CA). It provides TLS certificates to millions of websites.

## Let's encrypt clients

You can use a various number of tools created by different developers to issue a certificate from Let's encrypt. A good starting point is [certbot](https://certbot.eff.org/) client. It can obtain and install certificates for you. As this article will focus on ACME, so please excuse that we don't go deeper here.

## What is ACME v2

Since March 2018, it also supports ACME v2 (Automated Certificate Management Environment). Simplified, the following steps need to be taken to get a certificate:

1. Send in an order for a certificate
2. Prove that you have control over any identifiers requested in the certificate
3. Send the CSR to complete the order
4. Wait for the certificate to be issued and download it

### Validate control of domain

To prove you control the domain names in this certificate, ACME uses "Challenges". We will discuss only two challenges which can be used with Let's Encrypt:

#### HTTP-01

<!-- markdownlint-disable MD033 -->
The HTTP-01 challenge is a mostly used challenge. Your client creates a file on your webserver (`http://<YOUR_DOMAIN>/.well-known/acme-challenge/<TOKEN>`), where `<TOKEN>` corresponds to the token that gives Let's Encrypt to your ACME client. The file contains the token and a fingerprint of your account key.
<!-- markdownlint-enable MD033 -->

After creating the file, your client informs Let's Encrypt, and it tries to download the file and validates its content. If validation is successful, the client can proceed with issuing your certificate. If validation fails, you need to start a new request.

This challenge can only be performed against port 80/TCP.

Advantages:

- No DSN setup needed
- Works with all webserver types

Disadvantages:

- Works only if port 80/TCP is accessible
- Not applicable for wildcard certificates

#### DNS-01

The DNS-01 challenge works with special DNS resource records to prove your control over the domain you are requesting a certificate for. Let's Encrypt provides a token and your ACME client creates a TXT DNS record (`_acme-challenge.<YOUR_DOMAIN>`) in your DNS server. After creating this record, it will be looked up by Let's Encrypt. If the validation was successful, you can continue proceeding issuing the certificate.

As not all DNS providers offer the needed API for creating the DNS records, or you don't want to place the API credentials for your DNS provider on your webserver you can offload the TXT record handling to another service and create a CNAME for `_acme-challenge` to that service.

Advantages:

- Works for wildcard certificates
- No need to put a token on webserver

Disadvantages:

- API credentials on webserver can become an attack vector
- Necessary API is not available at all DNS providers

## ACME API

Unfortunately, not all DNS registrars provide the API for automation of the DNS-01 challenges. If they offer such an API, they often give the keys a far too many privileges, as forementioned this can become an attack vector for hackers.

With [acme-dns](https://github.com/joohoi/acme-dns) is there a lightweight DNS server with a RESTful HTTP API to handle ACME DNS challenges. It makes use of `CNAME` records to link your `_acme-challenge` to your `acme-dns` instance.

```dns
$ dig CNAME _acme-challenge.example.com

id 5041
opcode QUERY
rcode NOERROR
flags QR RD RA
;QUESTION
_acme-challenge.example.com. IN CNAME
;ANSWER
_acme-challenge.example.com. 60 IN CNAME 497ffe01-1b3a-4b2b-86e4-b02b173fa958.auth.example.com.
;AUTHORITY
;ADDITIONAL
```

## Running acme-dns

You can use `auth.acme-dns.io` but this is more a POC, so it is recommended to set up your own instance to have total control of your data.
In this article, we will show how to achieve this by running a container and linking it with your DNS zone.

We will put all under the `/opt` directory as follows:

```text
/opt/acme-dns/
├── config
│   └── config.cfg
└── data
```

The `config` directory will hold the configuration for all services running within the container. On first startup, `acme-dns` will create a sqlite3 database if this backend was chosen.

### Configuring acme-dns

To configure the service, you can use the configuration [template from](https://raw.githubusercontent.com/joohoi/acme-dns/master/config.cfg) the project page.

{: .box-note}
**Note:** This template will not create a fully functional service, as the DNS service will not be accessible.

The following configuration will work for us.

```text
[general]
listen = "0.0.0.0:53"
protocol = "both"
domain = "auth.example.com"
nsname = "auth.example.com"
nsadmin = "hostmaster.codeaffen.org"
records = [
    "auth.example.com. A 192.0.2.100",
    "auth.example.com. NS auth.example.com.",
]

[database]
engine = "sqlite3"
connection = "/var/lib/acme-dns/acme-dns.db"

[api]
ip = "0.0.0.0"
port = "80"
tls = "none"
disable_registration = false
```

The configuration is split into 4 different parts.

- `general` - settings for the DNS service
  - `listen` - needs to be configured to `0.0.0.0:53`, otherwise exposing the DNS ports is not possible
  - `protocol` - we set it to `both` as we want the DNS service should serve `tcp` and `udp`
  - The last parameters defines data for the SOA record and records that will be served addition to TXT records
- database - where would the data be saved
  - `engine` - we configured `sqlite3` as database backend
  - `connection` - is set to the path where the SQLite database will be saved
- api - configuration of the API endpoint
  - `ip` - defines on which port the api is listening. We configure the api to bind to all interfaces
  - `port` - we use port `80` for serving the api
  - `tls` - is set to `none` use the api only unencrypted on localhost
  - `disable_registration` - can be set to `true` if you want to prevent new registrations. This is only useful if you have already a registration

### acme-dns container

With the configuration above, you are ready to start the acme-dns container with the following command:

```shell
podman run --rm --name acmedns -d \
-p 53:53 -p 53:53/udp -p 80:80 \
-v /opt/acme-dns/config:/etc/acme-dns:ro,Z -v /opt/acme-dns/data:/var/lib/acme-dns:Z \
joohoi/acme-dns:v1.0
```

This will mount the configuration and the database directory into the container and expose ports for DNS service and the API.

### acme-dns systemd service

To start the acme-dns container each time your system starts, we create a [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) configuration.

{: .box-note}
**Note:** If you use a podman version lower than 4.4 you need to use `podman generate systemd`. We won't discuss these option here.

Place a file (e.g. acme-dns.container) in one directory of the quadlet search paths, in our example we create `/etc/containers/systemd/acme-dns.container`.

```systemd
[Unit]
Description=Limited DNS server with RESTful HTTP API to handle ACME DNS challenges easily and securely
After=local-fs.target

[Container]
Image=joohoi/acme-dns:v1.0
Volume=/opt/acme-dns/config:/etc/acme-dns:Z,ro
Volume=/opt/acme-dns/data:/var/lib/acme-dns:Z
PublishPort=53:53
PublishPort=53:53/udp
PublishPort=80:80
HealthCmd=/usr/bin/wget -q localhost/health -O /dev/nul

[Install]
# Start by default on boot
WantedBy=multi-user.target default.target
```

To make the systemd unit available and start the service, you need to run the following commands.

```shell
systemctl daemon-reload
systemctl start acme-dns.service
```

## Testing the service locally

After setting up the service, it's time to test your acme-dns service.

### Default DNS records

To check the basic functionality of the DNS part, you could run the following `dig` commands to resolve the default `A`, `NS` and `SOA` record.

```shell
$ for RR in A NS SOA ; do dig +noall +answer -t ${RR} -p 53 auth.example.com @localhost ; done
auth.example.com.       3600    IN      A       192.0.2.200
auth.example.com.       3600    IN      NS      auth.example.com.
auth.example.com.       3600    IN      SOA     auth.example.com. hostmaster.example.com. 2023112319 28800 7200 604800 86400
```

### Testing API & TXT records

If the first test went successfully, we want to test the API and the created TXT record.

First register an account at your acme-dns service.

```shell
$ curl -s -XPOST http://localhost/register | jq
{
  "username": "46ce673a-cc16-461e-b8bb-ed9386ab80b2",
  "password": "8OkorH-OCqowgxWDSyTAJp-GvECa0PL3Oni90fd7",
  "fulldomain": "794b5f85-18a8-4226-88e2-34b3dd50c761.auth.example.com",
  "subdomain": "794b5f85-18a8-4226-88e2-34b3dd50c761",
  "allowfrom": []
}
```

{: .box-note}
**Note:** You should save the output in a file (e.g. `acme-dns.json`). As the file contains sensitive data, you should put it in a safe place.

Second, you can create a TXT record and put some random text in it.

```shell
$ curl -s -XPOST http://localhost/update \
-H "X-Api-User: 46ce673a-cc16-461e-b8bb-ed9386ab80b2" \
-H "X-Api-Key: 8OkorH-OCqowgxWDSyTAJp-GvECa0PL3Oni90fd7" \
--data '{"subdomain": "794b5f85-18a8-4226-88e2-34b3dd50c761", "txt": "___validation_token_received_from_the_ca___"}' | jq
{
  "txt": "___validation_token_received_from_the_ca___"
}
```

Last, test if the DNS service resolves the newly created TXT record

```shell
$ dig +noall +answer -t TXT -p 53 794b5f85-18a8-4226-88e2-34b3dd50c761.auth.example.com @localhost
794b5f85-18a8-4226-88e2-34b3dd50c761.auth.example.com. 1 IN TXT "___validation_token_received_from_the_ca___"
```

## Setting up your public DNS

Now, as you know that the service runs as expected, you could configure your DNS zone to point to your acme-dns server. For that purpose, you need to create a `CNAME` resource record that points to the `fulldomain` value from the `acme-dns.json`.

```shell
$ dig +noall +answer -t CNAME _acme-challenge.acme-test.example.com @9.9.9.9
_acme-challenge.acme-test.example.com. 50 IN CNAME 794b5f85-18a8-4226-88e2-34b3dd50c761.auth.example.com.
```

If you now request a `TXT` record for that host, your acme-dns service will return the value of the record from your tests.

```shell
$ dig +noall +answer -t TXT _acme-challenge.acme-test.example.com @9.9.9.9
_acme-challenge.acme-test.example.com. 50 IN CNAME 794b5f85-18a8-4226-88e2-34b3dd50c761.auth.example.com.
794b5f85-18a8-4226-88e2-34b3dd50c761.auth.example.com. 1 IN TXT "___validation_token_received_from_the_ca___"
```

Et voilà! Your ACME setup is ready for a PKI for using it. Lastly, you can put an Apache or Nginx Webserver in front of the API to make it accessible via HTTPS or block the registration endpoint from outside your server.
