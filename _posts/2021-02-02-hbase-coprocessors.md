---
layout: post
title: How to remove coprocessor table attributes
subtitle: Coprocessors in HBase
tags: [apache, hadoop, hbase, phoenix, coprocessor]
author: gmzabos
---

{: .box-warning}
**WARNING** This has been tested on HBase running from Cloudera distribution version 5.16.1 & 6.3.4, but following this example, this will work on any other HBase distribution. We did this in our production environment, after several tests in development. It worked for us, but that's no guarantee that it will work for you. Read the docs & don't blame me for for any data loss.

## Intro on coprocessors

Coprocessors like [Apache Phoenix](http://phoenix.apache.org/){:target="_blank"} can add extra functionality to a HBase installation. In this case Apache Phoenix (as a bunch of extra .jar files) was added to the basic HBase installation path on every HBase RegionServer in our cluster, enabling **faster** SQL like queries. For the Cloudera distribution this is very easy, as it is just another parcel being downloaded, distributed & activated.

## The problem with coprocessor table attributes

As soon as you create a table or a view with an active coprocessor this adds extra table attributes to your HBase table. At some point you might decide that you don't want to use the coprocessor any longer, but the extra table attributes are preserved.

## Removing coprocessor table attributes

In our case a few "old" Hadoop clusters were about to be completely shut down and replaced by new Hadoop clusters, on new more performant hardware, also adding more security by activating Kerberos & SSL. One task was to move over the existing HBase ecosystem, consisting of ordinary tables, snapshots and a quite complex workflow on handling daily & monthly snapshots.

We identified two options on how to do this:

- use the database "dump" approach: export on the "old" clusters, import on the "new" clusters. The idea was dropped, as moving several hundred TB this way would not only consume cluster resources in terms of CPUs & memory, but also would exceed a reasonable time window (>72 hours).
- use [ExportSnapshot](https://hbase.apache.org/apidocs/org/apache/hadoop/hbase/snapshot/ExportSnapshot.html){:target="_blank"} to move snapshots to the new clusters. We decided on this, because it would be consuming less cluster resources and be much faster (<1 hour).

Unfortunately, the new clusters didn't have the Apache Phoenix coprocessor available (as we had discontinued using Apache Phoenix after an initial PoC). With this different setup, the import on the new clusters using ``clone_snapshot`` and/or ``restore_snapshot`` was failing, also resulting in the imported table being 'stuck', eventually having a negative impact on all other HBase procedures running on the new clusters.

This is how we did tackle this problem.

### Deactivate HBase sanity checks which are ACTIVE by default

- Make an entry in ``hbase-site.xml`` to set ``hbase.table.sanity.checks`` to ``false``
- Restart the HBase service

### Check & remove the extra table attributes from `hbase shell`

- Login to `hbase shell` as the **hbase** user
- the example uses a `DataCollection` table in the `Test` namespace

  ```text
  describe 'Test:DataCollection'
  disable 'Test:DataCollection'
  alter 'Test:DataCollection', METHOD => 'table_att_unset',NAME => 'coprocessor$1'
  alter 'Test:DataCollection', METHOD => 'table_att_unset',NAME => 'coprocessor$2'
  alter 'Test:DataCollection', METHOD => 'table_att_unset',NAME => 'coprocessor$3'
  alter 'Test:DataCollection', METHOD => 'table_att_unset',NAME => 'coprocessor$4'
  alter 'Test:DataCollection', METHOD => 'table_att_unset',NAME => 'coprocessor$5'
  enable 'Test:DataCollection'
  ```

- from ``hbase shell`` check the table state

  ```text
  get 'hbase:meta', 'Test:DataCollection', 'table:state'
  ```

- possible table states:

  ```text
  \x08\x00 (Enabled)
  \x08\x01 (Disabled)
  \x08\x02 (Disabling)
  \x08\x03 (Enabling)
  ```

- change the table state, ending up with a disabled table

  ```text
  put 'hbase:meta', 'Test:DataCollection', 'table:state',"\b\0"
  put 'hbase:meta', 'Test:DataCollection', 'table:state',"\b\1"
  ```

- do a final check of the table state, it should be disabled

  ```text
  get 'hbase:meta', 'Test:DataCollection', 'table:state'
  ```

### Activate sanity checks, bringing it back to the default configuration

- Remove the entry in ``hbase-site.xml`` to set ``hbase.table.sanity.checks`` back to default
- Restart the HBase service

### Drop the stuck table and check HDFS, Zookeeper & HBase

- Login to the ``hbase shell`` as the **hbase** user

  ```text
  drop 'Test:DataCollection'
  ```

- check the HBase directory in HDFS if gone

  ```text
  hdfs dfs -ls /hbase/data/Test
  ```

- check the HBase znode in Zookeeper if gone

  ```text
  hbase zkcli
  ls /hbase/table
  ```

- run ``hbase hbck`` and check if your tables are in ``Status: OK``

  ```text
  hbase hbck
  ```

With everything cleand up this problem was marked as solved, new clusters are now up & running, serving the data needed.
