---
layout: post
title: Discord as OpenShift alert receiver
subtitle: How to configure discord as a receiver for alertmanager
tags: [openshift, prometheus, alertmanager, discord, receiver, shorts, k8s]
author: cmeissner
---

Having alerts sent to a channel like Slack, E-Mail or Pagerduty is easy configured in OpenShift.

![Alertmanager receiver types](/assets/img/alertmanager_receiver_types.png)

Although there is an option to configure a webhook as a receiver type, it is not possible to use this for a discord webhook.

## Setup Discord

To use Discord as an alert target, you need to create an own instance. In that instance, you create a webhook as followed.

- Open `Server Settings` ⇾ `Integrations` ⇾ `Webhooks`
- Click `New Webhook`
- To configure the webhook you have to click on the angle bracket

  ![Discord webhook configuration](/assets/img/discord_webhook_configuration.png)

  Here you can set the `Name` of the Bot and the `Channel` where the messages should be sent to
- `Copy Webhook URL` by clicking the button of the same name

## Setup Alertmanager Receiver

As it is not possible yet to configure discord as a receiver type, you need to configure it in the YAML view in the Web UI or directly via console as followed.

- Export the existing configuration

  ```shell
  $ oc -n openshift-monitoring extract secret/alertmanager-main --keys=alertmanager.yaml
  alertmanager.yaml
  ```

  This will create a file `alertmanager.yaml`, which is used for the next step of configuration.

- Add a discord receiver type to your receivers

  ```yaml
  receivers:
  - name: default
    discord_configs:
      - webhook_url: >-
            <Webhook URL>
  - name: Watchdog
  ```

  Replace `<Webhook URL>` with the one you copied in while creating the webhook in the step before.

- Update your alertmanager configuration

  ```shell
  oc -n openshift-monitoring create secret generic alertmanager-main --from-file=alertmanager.yaml --dry-run=client -o=yaml |  oc -n openshift-monitoring replace secret --filename=-
  ```

  The `alertmanager-main-0` pod will recognize the change of the `alertmanager.yaml` and reload the configuration.

  You can monitor if the configuration was reloaded by observing the logs of the pod

  ```shell
  $ oc -n openshift-monitoring logs -f alertmanager-main-0
  ts=2023-12-27T17:51:43.531Z caller=coordinator.go:113 level=info component=configuration msg="Loading configuration file" file=/etc/alertmanager/config_out/alertmanager.env.yaml
  ts=2023-12-27T17:51:43.531Z caller=coordinator.go:126 level=info component=configuration msg="Completed loading of configuration file" file=/etc/alertmanager/config_out/alertmanager.env.yaml
  ```
