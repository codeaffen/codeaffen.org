---
layout: post
title: Cert Manager with ACME
subtitle: Issuing certificates in OpenShift with Let's Encrypt
tags: [cert-manager, openshift, k8s, acme, ssl, certificate, wildcard, letsencrypt, dns-server, tls-certificate, acme-challenge, acme-dns]
author: cmeissner
---

If you install an OCP cluster certificates for API and the wildcard domain will be signed by a self-signed CA.
This is not a security but a convenience issue as you need to accept or ignore warnings regarding self-signed certificates.

Replacing the certificates by ones signed by a known certificate authority is [well documented](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.14/html/security_and_compliance/configuring-certificates){:target="_blank"} and works well.
If you want to use Let's Encrypt as the CA of your choice, you can request certificates there and provide the authorization information on your own, but since the availability of [cert-manager Operator for Red Hat OpenShift](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.14/html/security_and_compliance/cert-manager-operator-for-red-hat-openshift){:target="_blank"} tools for managing certificates automatically available.

## Preparing for dns-01 challenge

If you have a working [acme-dns](/2023/12/01/wildcard_certs_with_acme/), it can be used to issue both host and wildcard certificates with cert-manager and Let's Encrypt.

1. Register an account with your acme-dns service and save the account data to a file

  ```shell
  $ curl -XPOST https://auth.example.com/register | jq > acmedns.json
  $ curl -s -XPOST https://auth.example.com/update \
  -H "X-Api-User: <username>" \
  -H "X-Api-Key: <password>" \
  --data '{"subdomain": "<subdomain>", "txt": "___validation_token_received_from_the_ca___"}' | jq
  {
    "txt": "___validation_token_received_from_the_ca___"
  }
  ```

  Replace the data between square brackets with the data from your registration.
2. Configure your DNS zone to forward dns-01 challenge requests to your acme-dns service

  ```shell
  $ dig +noall +answer -t CNAME _acme-challenge.apps.ocp4.example.com @9.9.9.9
  _acme-challenge.apps.ocp4.example.com. 50 IN CNAME <subdomain>.auth.example.com.

  ```

  Test whether a TXT record will be returned.

  ```shell
  $ dig +noall +answer -t TXT _acme-challenge.apps.ocp4.example.com @9.9.9.9
  _acme-challenge.apps.ocp4.example.com. 50 IN CNAME <subdomain>.auth.example.com.
  <subdomain>.auth.example.com. 1 IN TXT "___validation_token_received_from_the_ca___"
  ```

With these steps, the DNS setup is prepared for handling the dns-01 challenges.

## cert-manager Operator

As the DNS side of the setup has finished, it is now time to install the `cert-manager Operator for Red Hat OpenShift`.

1. Open the OpenShift web console. You need to log in as a cluster admin.
2. Navigate to the OperatorHub. Operator → OperatorHub
3. Search for `cert-manager`.
4. Select the `cert-manager Operator for Red Hat OpenShift` and click Install. In the upcoming wizard, leave all values on its defaults and click Install.

### Configure cert-manager

After installing the cert-manager Operator successfully, it is time to prepare it for issuing Let's Encrypt certificates. To do so, we need

1. Save the credentials json snippet from the registration process to a file with a key for all your domain that should be handled by the `ClusterIssuer`.

   As we want later replace the API and wildcard certificate with newly cert-manager created ones, the file should look like this.

    ```json
    {
      "api.ocp4.example.com": {
      "username": "<username>",
      "password": "<password>",
      "fulldomain": "<subdomain>.acme-dns.adsfg.xyz",
      "subdomain": "<subdomain>",
      "allowfrom": []
      },
      "apps.ocp4.example.com": {
      "username": "<username>",
      "password": "<password>",
      "fulldomain": "<subdomain>.acme-dns.adsfg.xyz",
      "subdomain": "<subdomain>",
      "allowfrom": []
      }
    }
    ```

   Save this data in a file (e.g. `acmedns.json`) and create a secret in the `cert-manager` project

   If you want to use `Issuer` in favor of a `ClusterIssuer` the secret needs to be created in the same project as the Issue will be created.

   ```shell
   $ oc -n cert-manager create secret generic acme-dns-staging --from-file acmedns.json=acmedns.json
    secret/acme-dns-staging created
   ```

   This secret and the key (`acmedns.json`) needs to be placed in the `ClusterIssuer` manifest.

2. Create a `ClusterIssuer` to handle the certificate issuing process

    ```shell
    $ cat <<EOF | oc create -f
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-staging
    spec:
      acme:
        email: hostmaster@cexample.com
        preferredChain: ""
        privateKeySecretRef:
          name: letsencrypt-staging-private-key
        server: https://acme-staging-v02.api.letsencrypt.org/directory
        solvers:
        - dns01:
            acmeDNS:
              accountSecretRef:
                key: acmedns.json
                name: acme-dns-staging
              host: https://auth.example.com
    EOF
    ```

    {: .box-note}
    **Note:** For this article, we use the staging instance of Let's Encrypt. You should do it also this way to check if the setup is working properly. Only after issuing a certificate successfully, you should switch to the production ACME endpoint. Otherwise, you risk running into rate limiting and being blocked from the API if anything does not work as expected.

## OCP certificates

To issue a certificate, it is needed to create a `Certificate` CR in the project where you need it. If you create a certificate, some corresponding custom resources will be created.

- CertificateRequest, is used to request a signed certificate
- Order, represents an order with an ACME server
- Challenge, represents a challenge request with an ACME server

![cert-manager flow](/assets/img/cert-manager-flow.png){:.mx-auto.d-block :}

### default ingress certificate

Unfortunately, it is not that easy to replace the ingress certificate as with upstream cert-manager and Kubernetes `Ingress` resources. In that case, only annotating the resource is needed to let the magic happen. See the original [documentation](https://cert-manager.io/docs/usage/ingress/){:target="_blank"} for details.

Replacing the default ingress certificate for the *.apps subdomain is a common day-2 task. Combining it with the use of cert-manager, it is really comfortable to have this automated for future updates of the related certificate.

1. Starting with creating a `Certificate` CR which uses the former configured `ClusterIssuer` to interact with the Let's Encrypt API.

    ```yaml
    $ cat <<EOF | oc create -f
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
    name: letsencrypt-staging-wildcard
    namespace: openshift-ingress
    spec:
    secretName: letsencrypt-staging-wildcard
    secretTemplate:
        labels:
        stage: staging
    duration: 2160h # 90d
    renewBefore: 360h # 15d
    isCA: false
    privateKey:
        algorithm: RSA
        encoding: PKCS1
        size: 2048
    usages:
        - server auth
        - client auth
    dnsNames:
        - apps.ocp4.example.com
        - '*.apps.ocp4.example.com'
    issuerRef:
        name: letsencrypt-staging
        kind: ClusterIssuer
        group: cert-manager.io
    EOF
    ```

2. After applying the manifest, the former discussed resources would be created, and you can monitor the status of the certificate by watching on it. As soon as the dns-01 challenge was solved the certificate will reach the ready state, and it can be used.

    ```shell
    $ oc -n openshift-ingress get certificates

    NAME                                                          READY   SECRET                            AGE
    certificate.cert-manager.io/letsencrypt-staging-wildcard      False   letsencrypt-staging-wildcard      9s
    ```

3. Patching the ingress controller after the certificate was issued is done by the following command.

    ```shell
    $ oc -n openshift-ingress-operator patch --type=merge ingresscontrollers/default --patch '{"spec":{"defaultCertificate":{"name":"letsencrypt-staging-wildcard"}}}'
    ingresscontroller.operator.openshift.io/default patched
    ```

   After patching the resource, the router pods will be restarted and the certificate will be used.

### API server certificate

To replace the default API server certificate, you need to run similar steps as with the default ingress certificate.

1. A `Certificate` resource need to be created as followed.

    ```shell
    $ cat <<EOF | oc create -f
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: letsencrypt-staging-api
      namespace: openshift-config
    spec:
      dnsNames:
      - api.ocp4.example.com
      duration: 2160h0m0s
      issuerRef:
        group: cert-manager.io
        kind: ClusterIssuer
        name: letsencrypt-staging
      privateKey:
        algorithm: RSA
        encoding: PKCS1
        size: 2048
      renewBefore: 360h0m0s
      secretName: letsencrypt-staging-api
      secretTemplate:
        labels:
          stage: staging
      usages:
      - server auth
      - client auth
    EOF
    ```

2. The status of the requested certificate can be monitored by watching the former created `Certificate` resource.

    ```shell
    $ oc -n openshift-config get certificates
    NAME                         READY   SECRET                       AGE
    letsencrypt-staging-api   True    letsencrypt-staging-api   122s
    ```

3. To replace the API server certificate with the newly created one, the following command is enough. It will patch the `Apiserver` resource and a restart of the apiserver pods will be initiated.

    ```shell
    $ oc patch apiserver/cluster --type=merge -p '{"spec":{"servingCerts": {"namedCertificates": [{"names": ["api.ocp4.example.com"], "servingCertificate": {"name": "letsencrypt-staging-api"}}]}}}'
    apiserver.config.openshift.io/cluster patched
    ```
