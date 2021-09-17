---
layout: post
title: 5 Steps to migrate Helm Charts from Chartmuseum to Redhat Quay
subtitle: How to move from repository to registry
tags: [kubernetes, openshift, helm, chart, repository, redhat, quay, registry]
author: gmzabos
---

An instance of Chartmuseum repository is up & running for months now and does serve Helm Charts. An instance of Redhat Quay has been built up in parallel, but has been solely used for storing container images until now.

# But why?

With [Redhat Quay 3.5 (GA)](https://cloud.redhat.com/blog/quay-oci-artifact-support-for-helm-charts){:target="_blank"} it's possible to activate & use OCI Artifact Support for Helm charts, storing now both -container images & Helm Charts- in the same place. This and additional features of Redhat Quay made the decision easy to move the existing Helm Charts from Chartmuseum to Redhat Quay.

## What is Chartmuseum?

[Chartmuseum](https://github.com/helm/chartmuseum/){:target="_blank"} is an open-source Helm Chart repository server written in Go (Golang). Basically it's a HTTP server that serves packaged Helm Charts and an `index.yaml` file, which is an index of all Helm Charts in the repository.

## What is Redhat Quay?

[Redhat Quay](https://www.redhat.com/en/technologies/cloud-computing/quay){:target="_blank"} is an image registry. It comes with additional, enterprise-ready features (e.g. access control management, logging/auditing, etc.).

## Prerequisites

- Chartmuseum is up & running, serving via a known API URL (e.g. https://chartmuseum.local.net)
- An admin host is up & running. The `helm` binary is release v3.x or higher (see: `helm version`), you have set an extra environment variable:
  ~~~shell
  export HELM_EXPERIMENTAL_OCI=1
  ~~~
- Redhat Quay version 3.5+ is up & running, serving via a known URL (e.g https://quay.local.net)
- Redhat Quay has an active user/organization (e.g. `my-helm-charts`)
- Redhat Quay configuration file `config.yaml` has two properties set to enable the use of OCI artifacts:
  ~~~text
  FEATURE_GENERAL_OCI_SUPPORT: true
  FEATURE_HELM_OCI_SUPPORT: true
  ~~~

## Step 1 - Connect your Chartmuseum repository

~~~shell
helm repo add chartmuseum https://chartmuseum.local.net
helm repo update
helm repo list
~~~

## Step 2 - Connect your Redhat Quay registry

~~~shell
helm registry login quay.local.net
~~~

## Step 3 - Pull your Helm Chart 'webserver' from Chartmuseum repository, tag it for Redhat Quay registry

~~~shell
helm pull chartmuseum/webserver --version=0.0.1 --untar
helm chart save ./webserver quay.local.net/my-helm-charts/webserver:0.0.1
helm chart list
~~~

## Step 4 - Push your Helm Chart 'webserver' to Redhat Quay registry, delete local

~~~shell
helm chart push quay.local.net/my-helm-charts/webserver:0.0.1
helm chart rm quay.local.net/my-helm-charts/webserver:0.0.1
helm chart list
~~~

## Step 5 - Pull your Helm Chart 'webserver' from Redhat Quay registry, edit on local filesystem & deploy

~~~shell
helm chart pull quay.local.net/my-helm-charts/webserver:0.0.1
helm chart export quay.local.net/my-helm-charts/webserver:0.0.1
vi webserver/Chart.yaml
vi webserver/values.yml
helm install webserver
~~~

# Summary

With this simplified five step demonstration you should be able to get the idea, how to migrate your Helm Charts to Redhat Quay registry. Depending on the amount of Helm Charts, the workflow can be automated. This can make sense if both -Chartmuseum repository & Redhat Quay registry- coexist for a longer time and you need to have a synchronisation of both in place.