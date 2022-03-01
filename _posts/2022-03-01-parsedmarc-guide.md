---
layout: post
title: Open source anti spam monitoring tool
subtitle: Use parsedmarc to monitor your DMARC results
cover-img: /assets/img/parsedmarc_header.png
thumbnail-img: /assets/img/DMARC-logo.png
author: cmeissner
tags: [parsedmarc, dmarc, spf, dkim, anti spam, elasticsearch, kibana]
---

DMARC stands for "Domain-based Message Authentication, Reporting and Conformance". It is as protocol for email authentication, policy and reporting.
It based on [SPF](https://dmarc.org/wiki/Glossary#SPF){:target="_blank"} and [DKIM](https://dmarc.org/wiki/Glossary#DKIM) protocol which are widely used by email providers and mail server operators to authenticate and verify emails.

DMARC links sender authentication checks and receipient handling in case of authentication failures. Furthermore it adds reporting from receivers to senders to provide a facility to monitor and control the email protection.

## Deploy DMARC for your domain

DMARC policy lets you configure to indicate that your domain is protected by SPF and DKIM.\
You need to publish a TXT resource record for the domain in your DNS zone. This resource record helps you to control what happens if SPF or DKIM fails.

{% highlight text %}
.   TXT     "v=DMARC1; p=reject; sp=reject; pct=100; rua=mailto:postmaster@example.com"
{% endhighlight %}

Following you find a list of all parameters available for configuring DMARC.

Tag | Purpose | Sample |
--- | --- | --- |
v | Protocol version | v=DMARC1
pct | Percentage of messages subjected to filtering | pct=20
ruf | Reporting URI for forensic reports | ruf=mailto:forensics@[]()example.com
rua | Reporting URI of aggregate reports | rua=mailto:postmaster@[]()example.com
p | Policy for organizational domain | p=quarantine
sp | Policy for subdomains of the OD | sp=reject
adkim | Alignment mode for DKIM | adkim=s
aspf | Alignment mode for SPF | aspf=r

## monitoring and visualisation with parsedmarc

The reports are sent to the email addresses configured in `ruf` and `rua` parameters in DMARC TXT resource record in xml format.

<!-- markdownlint-disable MD033 -->
{::options parse_block_html="true" /}
<details><summary markdown="span">Example for aggregated DMARC report</summary>
{% highlight xml linenos %}
{% raw %}
<?xml version="1.0" encoding="UTF-8" ?>
<feedback>
  <report_metadata>
    <org_name>google.com</org_name>
    <email>noreply-dmarc-support@google.com</email>
    <extra_contact_info>https://support.google.com/a/answer/2466580</extra_contact_info>
    <report_id>17267560027217318633</report_id>
    <date_range>
      <begin>1645574400</begin>
      <end>1645660799</end>
    </date_range>
  </report_metadata>
  <policy_published>
    <domain>example.com</domain>
    <adkim>r</adkim>
    <aspf>r</aspf>
    <p>reject</p>
    <sp>reject</sp>
    <pct>100</pct>
  </policy_published>
  <record>
    <row>
      <source_ip>209.85.220.69</source_ip>
      <count>1</count>
      <policy_evaluated>
        <disposition>none</disposition>
        <dkim>pass</dkim>
        <spf>pass</spf>
      </policy_evaluated>
    </row>
    <identifiers>
      <header_from>example.com</header_from>
    </identifiers>
    <auth_results>
      <dkim>
        <domain>example.com</domain>
        <result>pass</result>
        <selector>default</selector>
      </dkim>
      <spf>
        <domain>example.com</domain>
        <result>pass</result>
      </spf>
    </auth_results>
  </record>
</feedback>
{% endraw %}
{% endhighlight %}
</details>
{::options parse_block_html="false" /}
<!-- markdownlint-enable MD033 -->

For visualisation and monitoring there are some popular commercial tools outside. Some of them are:

* [Agari Brand Protection](https://www.agari.com/products/brand-protection/){:target="_blank"}
* [Dmarcian](https://dmarcian.com/){:target="_blank"}
* [OnDMARC](https://redsift.com/products/ondmarc){:target="_blank"}
* [ProofPoint Email Fraud Defense](https://www.proofpoint.com/us/products/email-protection/email-fraud-defense){:target="_blank"}
* [Valimail](https://www.valimail.com/){:target="_blank"}

It is absolutly fine to use one of these tools but if you are not willing to use a commercial tool and you have some time and knowledge you can setup a free toolchain as your DMARC monitoring tool.

This is where [parsedmarc](https://github.com/domainaware/parsedmarc){:target="_blank"} comes into play. It is a simple python library which can be used to parse DMARC reports and visualize them.

![parsedmarc overview](/assets/img/parsedmarc_elastic_overview.png)

### Setup

Installation of parsedmard is done with pip as any other python library. We don't want to cover this here but we want to show how to setup the whole toolchain.

In our example we use IMAP to grap DMARC reports, send the extracted data to elasticsearch and visualize the data with kibana.

#### configure elasticsearch

As we use elasticsearch as our monitoring backend and our elasticsearch cluster needs authentication we need to create a role and a user for that user.

For that we use the following json snippets send to the corresponding RestAPI endpoint of elasticsearch.

**POST /_security/role/parsedmarc**
{% highlight json linenos %}
{% raw %}
{
  "cluster": [ ],
  "indices": [
    {
      "names": [
        "dmarc_aggregate*",
        "dmarc_forensic*"
      ],
      "privileges": [
          "read",
          "write",
          "view_index_metadata",
          "create",
          "delete",
          "create_index"
      ]
    }
  ]
}
{% endraw %}
{% endhighlight %}

**POST /_security/user/dmarcingest**
{% highlight json linenos %}
{% raw %}
{
  "password" : "dm4rcp455w0rd",
  "roles" : [ "parsedmarc"],
  "full_name" : "User for Ingesting DMARC information"
}
{% endraw %}
{% endhighlight %}

{: .box-note}
**Note:** As an alternative to the RestAPI you can use kibana's [role](https://www.elastic.co/guide/en/kibana/current/tutorial-secure-access-to-kibana.html#_create_a_role){:target="_blank"} and [user management](https://www.elastic.co/guide/en/kibana/current/tutorial-secure-access-to-kibana.html#_create_a_user){:target="_blank"} feature.
{: .box-note}

#### parsedmarc config file

Now we have to create a config file with the following content.

<!-- markdownlint-disable MD033 -->
{::options parse_block_html="true" /}
<details><summary markdown="span">parsedmarc.ini</summary>
{% highlight ini linenos %}
{% raw %}
[general]
save_aggregate = True
save_forensic = True

[imap]
host = imap.example.com
user = imapuser
password = v3ryS3cr3t
ssl = true
reports_folder = my/imap/folder
watch = True

[elasticsearch]
hosts = https://dmarcingest:dm4rcp455w0rd.@elastic.example.com:9200
cert_path = /etc/parsedmarc/elastic_ca.crt
ssl = True
{% endraw %}
{% endhighlight %}
</details>
{::options parse_block_html="false" /}
<!-- markdownlint-enable MD033 -->

As we want to run parsedmarc as systemd service we put all files belongs to parsedmarc in a directory called `/etc/parsedmarc`.
In this directory we also place the ca certificate for the elasticsearch connection.

With this configuration you are already able to run `parsedmarc` to import report data into elasticsearch.

~~~shell
# parsedmarc -c /etc/parsedmarc/parsedmarc.ini
~~~

This starts a parsedmarc mailbox listener and imports the reports into elasticsearch.

#### configure kibana

We suggest to create a separate kibana [space](https://www.elastic.co/guide/en/kibana/current/tutorial-secure-access-to-kibana.html#_create_a_space){:target="_blank"} for the DMARC.

And we alos can create a role and user to only have read-only access to the space to view DMARC dashboards.

**POST _security/role/parsedmarc_viewer**
{% highlight json linenos %}
{% raw %}
{
  "cluster": [],
  "indices": [
    {
      "names": [
        "dmarc_forensic*",
        "dmarc_aggregate*",
        "parsedmarc"
      ],
      "privileges": [
        "read",
        "view_index_metadata"
      ],
      "allow_restricted_indices": false
    }
  ],
  "applications": [
    {
      "application": "kibana-.kibana",
      "privileges": [
        "feature_dashboard.read"
      ],
      "resources": [
        "space:dmarc"
      ]
    }
  ],
}
}
{% endraw %}
{% endhighlight %}

**POST /_security/user/parsedmarc_viewer**
{% highlight json linenos %}
{% raw %}
{
  "password" : "v3ryS3cr3t",
  "roles" : [ "parsedmarc_viewer"],
  "full_name" : "User for viewing DMARC dashboards"
}
{% endraw %}
{% endhighlight %}

#### dashboards and index patterns

To visualize the data we need to create dashboards and index patterns. This is done by importing the [export.ndjson](https://raw.githubusercontent.com/domainaware/parsedmarc/master/kibana/export.ndjson){:target="_blank"} (use the save link as option) file. This file contains two dashboards and two index patterns.

This task id done by using the [Saved Objects UI](https://www.elastic.co/guide/en/kibana/current/managing-saved-objects.html){:target="_blank"}.

{: .box-note}
**Note:** If you create a separate space for your DMARC work you have to import the dashboards and index patterns into that space.
{: .box-note}

#### running parssedmarc as systemd service

As for now we have setup elasticsearch, kibana and parsedmarc to import data and visualize it. As for now we have to start the parsedmarc service manually. This is not very convinient so we go ahead and setup systemd service.

First of all we want to run the service with non-root privileges so we need to create a user and a group. And we also want to restrict the access to parsedmarc configuration directory to that user and group.

~~~bash
groupadd -r parsedmarc
useradd -rL parsedmarc -g parsedmarc
chown -R parsedmarc:parsedmarc /etc/parsedmarc
chmod -R 750 /etc/parsedmarc
~~~

As we already have save our `parsedmarc.ini` and `elastic_ca.crt` files we now need to create a systemd unit file with the following content.

<!-- markdownlint-disable MD033 -->
{::options parse_block_html="true" /}
<details><summary markdown="span">/etc/systemd/system/parsedmarc.service</summary>
{% highlight ini linenos %}
{% raw %}
[Unit]
Description=parsedmarc mailbox watcher
Documentation=https://domainaware.github.io/parsedmarc/
Wants=network-online.target
After=network.target network-online.target elasticsearch.service

[Service]
ExecStart=/usr/local/bin/parsedmarc -c /etc/parsedmarc/parsedmarc.ini
User=parsedmarc
Group=parsedmarc
Restart=always
RestartSec=5m

[Install]
WantedBy=multi-user.target
{% endraw %}
{% endhighlight %}
</details>
{::options parse_block_html="false" /}
<!-- markdownlint-enable MD033 -->

With this configuration we are ready to enable and start the parsedmarc service as follows.

~~~shell
systemctl daemon-reload
systemctl enable parsedmarc.service
service parsedmarc start
~~~

### Conclusion

DMARC is a very useful protocol to indicate that your mail server is protected against spam and phishing by spf and dkim and it implements a policy what should happen if a mail is not compliant with the policy.

It also implements a facility to get reports of the dmarc results via email in a common xml formant.

To monitor the dmarc compliance you can choose a commercial solution but you can also use free software to implement a visualisation stack on your own. We show you how to setup eleasticsearch, kibana and parsedmarc to achieve this.

Now you should be able to monitor the success of your dmarc setup. We hope that you find this tutorial helpful and that you can use it to implement your own dmarc solution.
