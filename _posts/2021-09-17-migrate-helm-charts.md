---
layout: post
title: Helm Charts from ChartMuseum to Red Hat Quay in 5 Steps
subtitle: How to migrate from repository to registry
tags: [kubernetes, openshift, helm, chart, repository, , quay, registry]
author: gmzabos
last-updated: 2022-07-03
---

Imagine the following situation you have an instance of ChartMuseum repository up & running for months now and it does serve Helm Charts. You also build up an instance of Red Hat Quay in parallel, but it has been solely used for storing container images until now.

## But why?

With [Red Hat Quay 3.5 (GA)](https://cloud.redhat.com/blog/quay-oci-artifact-support-for-helm-charts){:target="_blank"} it's possible to activate & use OCI Artifact Support for Helm charts, storing now both -container images & Helm Charts- in the same place. This and additional features of Red Hat Quay made the decision easy to move the existing Helm Charts from ChartMuseum to Red Hat Quay.

### What is ChartMuseum?

[ChartMuseum](https://github.com/helm/chartmuseum/){:target="_blank"} is an open-source Helm Chart repository server written in Go (Golang). Basically it's a HTTP server that serves packaged Helm Charts and an `index.yaml` file, which is an index of all Helm Charts in the repository.

### What is Red Hat Quay?

[Red Hat Quay](https://www.redhat.com/en/technologies/cloud-computing/quay){:target="_blank"} is an image registry. It comes with additional, enterprise-ready features (e.g. access control management, logging/auditing, etc.).

### Prerequisites

- ChartMuseum is up & running, serving via a known API URL (e.g. https://chartmuseum.local.net)
- An admin host is up & running. The `helm` binary is release v3.x or higher (see: `helm version`), you have set an extra environment variable:

~~~shell
export HELM_EXPERIMENTAL_OCI=1
~~~

- Red Hat Quay version 3.5+ is up & running, serving via a known URL (e.g https://quay.local.net)
- Red Hat Quay has an active user/organization (e.g. `my-helm-charts`)
- Red Hat Quay configuration file `config.yaml` has two properties set to enable the use of OCI artifacts:

~~~text
FEATURE_GENERAL_OCI_SUPPORT: true
FEATURE_HELM_OCI_SUPPORT: true
~~~

### Step 1 - Connect ChartMuseum repository

First of all you have to add your ChartMuseum instance as a repo to your helm installation.

~~~shell
helm repo add ChartMuseum https://chartmuseum.local.net
helm repo update
helm repo list
~~~

### Step 2 - Connect Red Hat Quay registry

Next you have to add your Quay instance as a registry to your helm instance.

~~~shell
helm registry login quay.local.net
~~~

### Step 3 - Pull and tag

Now you can pull a Helm Chart (e.g. ‘webserver’) from your repository and tag it for pushing to your registry.

~~~shell
helm pull ChartMuseum/webserver --version=0.0.1 --untar
helm chart save ./webserver quay.local.net/my-helm-charts/webserver:0.0.1
helm chart list
~~~

### Step 4 - Push

Now you can push your the Helm Chart which you pulled before to you registry. After that you can delete it locally.

~~~shell
helm chart push quay.local.net/my-helm-charts/webserver:0.0.1
helm chart rm quay.local.net/my-helm-charts/webserver:0.0.1
helm chart list
~~~

### Step 5 - Pull Chart from Quay

From now on you are able to pull your Helm Chart from your registry. You can edit it on local filesystem and deploy it as normal.

~~~shell
helm chart pull quay.local.net/my-helm-charts/webserver:0.0.1
helm chart export quay.local.net/my-helm-charts/webserver:0.0.1
vi webserver/Chart.yaml
vi webserver/values.yml
helm install webserver
~~~

## Summary

With this simplified five step demonstration you should be able to get the idea, how to migrate your Helm Charts to Red Hat Quay registry. Depending on the amount of Helm Charts, the workflow can be automated. This can make sense if both -ChartMuseum repository & Red Hat Quay registry- coexist for a longer time and you need to have a synchronisation of both in place.
