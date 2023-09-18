---
layout: post
title: Managing LocalVolumeSet of Local Storage Operator
subtitle: How to manage disks of a Local Volume Set
tags: [openshift, operator, local-storage-operator, localvolumeset, localdiscovery]
author: cmeissner
redirect_from: /2023-08-12-manage_localvolumeset/
---

If you use OpenShift Data Foundation in you environment and you want to use local disks of your worker/infra nodes then the Local Storage operator could be your choice.

This operator provides some nice CRDs to automatically discover attached devices and provide available once for using them in a LocalVolumeSet. Such a LocalVolumeSet results in a Storage Class resource which can be uses for a ODF storage system.

## Lab environment

To test our solution we installed an OpenShift cluster with 3 control plane and 3 worker nodes. We also attached 3x 100GB volumes to each worker node.

In the cluster we installed the `Local Storage` and `OpenShift Data Foundation` operators from `OperatorHub`. Please have a look into the official documentation for details.


## Configuring Local Storage Operator

### LocalVolume Discovery

A great plus of Locale Storage Operator is that you have the ability to let free storage devices be discovered automatically.

```shell
$ cat <<EOF | oc apply -f
apiVersion: local.storage.openshift.io/v1alpha1
kind: LocalVolumeDiscovery
metadata:
  name: auto-discover-devices
  namespace: openshift-local-storage
spec:
  nodeSelector:
    nodeSelectorTerms:
      - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
              - worker0
              - worker1
              - worker2
EOF
localvolumediscovery.local.storage.openshift.io/auto-discover-devices created
```

### LocalVolumeSet

A Volume Set creates some resources to making local storage devices usable for e.g. ODF. You can create a LocalVolumeSet via CLI with this command:

```shell
$ cat <<EOF | oc apply -f -
apiVersion: local.storage.openshift.io/v1alpha1
kind: LocalVolumeSet
metadata:
  name: localvolumeset01
  namespace: openshift-local-storage
spec:
  nodeSelector:
    nodeSelectorTerms:
    - matchExpressions:
      - key: kubernetes.io/hostname
        operator: In
        values:
        - worker01
        - worker02
        - worker03
  storageClassName: localvolumeset01
  volumeMode: Block
```

This will create a `LocalVolumeSet` and `StorageClass` with name `localvolumeset01` and all available devices will be allocated.

## Fixing LocalVolumeSet

If you want to decrease the amount of used disks you have to be careful and need to go through different steps to achieve it. We will show two situations with a detailed step-by-step guides to solve it.

### missing maxDeviceCount

A LocalVolumeSet will allocate all available disks if you don´t configure the `maxDeviceCount` parameter in your resource definition.

{: .box-warning}
**Warning:** If you add or decrease the `maxDeviceCount` parameter there will be no disks removed from the LocalVolumeSet. You need to do some extra steps to reduce the allocated disk count.

{: .box-error}
**Caution:** The following procedure could harm your cluster storage. It is absolutely recommended to have a backup of your data in place.

{: .box-note}
If there are `PersistenVolumens` attached to the desired `StorageClass` in status `Available` you could proceed.

If you forgot to configure the `maxDeviceCount` parameter by accident we show now how To fix this issue:

1. check current Persistent Volumens

    ```shell
    $ oc get pv -o custom-columns="NAME:.metadata.name,STORAGECLASS:.spec.storageClassName,STATUS:.status.phase"
    NAME                STORAGECLASS       STATUS
    local-pv-29c38c6c   localvolumeset01   Available
    local-pv-54490209   localvolumeset01   Available
    local-pv-56e97b91   localvolumeset01   Available
    local-pv-7a680599   localvolumeset01   Available
    local-pv-7b5248ad   localvolumeset01   Available
    local-pv-898e1c0f   localvolumeset01   Available
    local-pv-dc884927   localvolumeset01   Available
    local-pv-e97fdb50   localvolumeset01   Available
    local-pv-f88de77b   localvolumeset01   Available
    ```

2. patch miscofigured `LocalVolumeSet`

    ```shell
    $ oc patch localvolumeset/localvolumeset01 --type merge -p '{"spec": {"maxDeviceCount": 2}}' -n openshift-local-storage
    localvolumeset.local.storage.openshift.io/localvolumeset01 patched
    ```


3. remove disk assignment from nodes

    ```shell
    $ for node in $(oc get nodes -l cluster.ocs.openshift.io/openshift-storage -o name)
      do
      oc debug $node -- chroot /host rm -Rf /mnt/local-storage/localvolumeset01
      done
    Temporary namespace openshift-debug-XXXXX is created for debugging node...
    Starting pod/worker0-debug ...
    To use host binaries, run `chroot /host`

    Removing debug pod ...
    Temporary namespace openshift-debug-XXXXX was removed.
    ```

4. remove persistent Volumes related to Local Volume Set

    ```shell
    $ oc delete pv -l storage.openshift.com/owner-name=localvolumeset01                                                                                                <aws:remove_localvolumeset> <region:eu-central-1>
    persistentvolume "local-pv-XXXXXXXX" deleted
    ...
    ```

    Right after deleting all the Persistent Volumes for the Local Volume Set new PVs will be created. But only the amount of PVs needed to fullfil the `maxDeviceCount` request.

After a while you should see that only three Persistent Volumes are linked to our Storage Class `localvolumeset01`.

### decrease disk count

While increasing the disk count is very simple by simply increasing the value of `maxDeviceCount` to the desired number of disks per node but decreasing the number of allocated disks is not this easy. We will show how the task can still be solved.

{: .box-error}
**Caution:** The following procedure could harm your cluster storage. It is absolutely recommended to have a backup of your data in place.

{: .box-note}
If there are `PersistentVolumes` attached to the desired `StorageClass` in status `Available` you could proceed.

In our example we have increased the `maxDeviceCount` to 2 by accident but we want to decrease the value back to 1. To achieve this we need to follow this procedere.

1. set the value for `maxDeviceCount` to the desired value. In our example to `1`.

    ```shell
    $ oc patch localvolumeset/localvolumeset01 --type merge -p '{"spec": {"maxDeviceCount": 1}}' -n openshift-local-storage
    localvolumeset.local.storage.openshift.io/localvolumeset01 patched

    ```

    This prevents the LocalVolumeSet from claiming the devices again after releasing them.

2. check current Persistent Volumes

    ```shell
    $ oc get pv -o custom-columns="NAME:.metadata.name,STORAGECLASS:.spec.storageClassName,STATUS:.status.phase"
    NAME                STORAGECLASS       STATUS
    local-pv-29c38c6c   localvolumeset01   Available
    local-pv-56e97b91   localvolumeset01   Bound
    local-pv-7b5248ad   localvolumeset01   Bound
    local-pv-898e1c0f   localvolumeset01   Available
    local-pv-e97fdb50   localvolumeset01   Bound
    local-pv-f88de77b   localvolumeset01   Available
    ```

    The listing show 3 Persistent Volumes which are not claimed right now. These PVs and the corresponding disks we want to set free.

3. get node name and paths associated to devices of each pv

    To release the disks we need to know the mount path and the corresponding node name. To get this data we request all PV resource definitions in json format and pipe it through `jq`. In `jq` we filter all pvs in status `Available` and create dicts with the data we need for the next step.

    ```shell
    $ oc get pv -o json | jq '.items[] | select(.status.phase == "Available") | {host: .metadata.labels."kubernetes.io/hostname", path: .spec.local.path}'
    {
    "host": "worker01",
    "path": "/mnt/local-storage/localvolumeset01/nvme-Amazon_Elastic_Block_Store_vol04394cee5d42a5798"
    }
    {
    "host": "worker02",
    "path": "/mnt/local-storage/localvolumeset01/nvme-Amazon_Elastic_Block_Store_vol06d44ab8817b4e34c"
    }
    {
    "host": "worker03",
    "path": "/mnt/local-storage/localvolumeset01/nvme-Amazon_Elastic_Block_Store_vol0abea49b773396ffa"
    }
    ```

4. remove association to devices from each node

    You can either go through the output from the prior command or you use the following loop to achieve the task programmatically:

    ```shell
    while read -r h p
    do
    oc debug node/${h} -- chroot /host rm $p
    done < <(oc get pv -o json | jq '.items[] | select(.status.phase == "Available") | {host: .metadata.labels."kubernetes.io/hostname", path: .spec.local.path}' | jq -r '.host + " " + .path')
    ```

5. delete corresponding PVs

    As there is now no disk attached to the local devices on each node we can safely remove the corresponding Persistent Volumes.

    ```shell
    oc delete pv $(oc get pv -o json | jq -r '.items[] | select(.status.phase == "Available") | .metadata.name')
    persistentvolume "local-pv-29c38c6c" deleted
    persistentvolume "local-pv-898e1c0f" deleted
    persistentvolume "local-pv-f88de77b" deleted
    ```
