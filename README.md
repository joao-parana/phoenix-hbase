phoenix-hbase
=============

A Docker image to quick start [Apache Phoenix](http://phoenix.apache.org/) on [Apache HBase](https://hbase.apache.org/)
to provide an SQL interface.

Apache Phoenix is a SQL skin over HBase delivered as a client-embedded JDBC driver targeting low latency queries over HBase data.
Apache Phoenix takes your SQL query, compiles it into a series of HBase scans, and orchestrates the running of those scans to produce regular JDBC result sets.
The table metadata is stored in an HBase table and versioned, such that snapshot queries over prior versions will automatically use the correct schema.
Direct use of the HBase API, along with coprocessors and custom filters, results in performance on the order of milliseconds for small queries, or seconds for tens of millions of rows.

### Versions
ZooKeeper 3.4.6
Apache Hadoop - 2.7.1
Apache HBase - 1.2.5
Apache Phoenix - 4.10.0

### Build Docker Image

```bash
docker build -t parana/docker-phoenix .
```

### Launch

Normal interactive launch

```bash
docker run -it --rm parana/docker-phoenix
``` 

### Alternative launch

To launch directly the sqlline for phoenix you can do this:

```bash
docker run -it parana/docker-phoenix /etc/bootstrap-phoenix.sh -sqlline
```

### Troubleshooting

If you just want to run HBase without going into Zookeeper management for
standalone HBase, then remove all the `property` blocks from `hbase-site.xml`
except the property block named `hbase.rootdir`. 

Now run `/bin/start-hbase.sh`. HBase comes with its own Zookeeper,
which gets started when you run `/bin/start-hbase.sh`, which will suffice
if you are trying to get around things for the first time. Later you can
put distributed mode configurations for Zookeeper.

You only need to run `/sbin/start-dfs.sh` for running HBase since the value
of `hbase.rootdir` is set to `hdfs://127.0.0.1:9000/hbase` in your
`hbase-site.xml`. If you change it to some location on local the filesystem
using `file:///some_location_on_local_filesystem`, then you don't even need
to run  `/sbin/start-dfs.sh`. 

`hdfs://127.0.0.1:9000/hbase` says it's a place on HDFS and `/sbin/start-dfs.sh`
starts namenode and datanode which provides underlying API to access the HDFS
file system. For knowing about Yarn, please look at
[http://hadoop.apache.org/docs/r2.7.3/hadoop-yarn/hadoop-yarn-site/YARN.html](http://hadoop.apache.org/docs/r2.7.3/hadoop-yarn/hadoop-yarn-site/YARN.html).


You can need to stop/start zookeeper and then run Hbase-shell 

    {HBASE_HOME}/bin/hbase-daemons.sh {start,stop} zookeeper

and you may want to check this property in hbase-env.sh

    # Tell HBase whether it should manage its own instance of Zookeeper or not.
    export HBASE_MANAGES_ZK=false

Refer to [Zookeeper](http://hbase.apache.org/book.html#zookeeper)

#### Try with another image

```
cd legacy
docker build -t parana/docker-phoenix-master .
docker save -o docker-phoenix-master.tar  parana/docker-phoenix-master:latest
scp -P 49133 docker-phoenix-master.tar  parana@my-remote-host:~/
# On my-remote-host I need to do:
docker load -i docker-phoenix-master.tar  -q
docker images
docker run -it parana/docker-phoenix-master /etc/bootstrap-phoenix.sh -sqlline
```


#### Testing

```sql
CREATE TABLE IF NOT EXISTS us_population (
      state CHAR(2) NOT NULL,
      city VARCHAR NOT NULL,
      population BIGINT
      CONSTRAINT my_pk PRIMARY KEY (state, city));

UPSERT into us_population (state, city, population) values ('NY','New York',8143197);
UPSERT into us_population (state, city, population) values ('CA','Los Angeles',3844829);
UPSERT into us_population (state, city, population) values ('IL','Chicago',2842518);
UPSERT into us_population (state, city, population) values ('TX','Houston',2016582);
UPSERT into us_population (state, city, population) values ('PA','Philadelphia',1463281);
UPSERT into us_population (state, city, population) values ('AZ','Phoenix',1461575);
UPSERT into us_population (state, city, population) values ('TX','San Antonio',1256509);
UPSERT into us_population (state, city, population) values ('CA','San Diego',1255540);
UPSERT into us_population (state, city, population) values ('TX','Dallas',1213825);
UPSERT into us_population (state, city, population) values ('CA','San Jose',912332);

  SELECT state, count(city) as "city count", sum(population) as "population sum"
    FROM us_population
GROUP BY state
ORDER BY sum(population) DESC;
```


## More About HBase

Why do we need NoSQL?

The Relational Databases have the following challenges:

Not good for large volume (Petabytes) of data with variety of data types (eg. images, videos, text)
* Cannot scale for large data volume
* Cannot scale-up, limited by memory and CPU capabilities
* Cannot scale-out, limited by cache dependent Read and Write operations
* Sharding (break database into pieces and store in different nodes) causes operational problems (e.g. managing a shared failure)
* Complex RDBMS model
* Consistency limits the scalability in RDBMS

Compared to relational databases, NoSQL databases are more scalable and provide superior performance. NoSQL databases address the challenges that the relational model does not by providing the following solution:

* A scale-out, shared-nothing architecture, capable of running on a large number of nodes
* A non-locking concurrency control mechanism so that real-time reads will not conflict writes
* Scalable replication and distribution – thousands of machines with distributed data
* An architecture providing higher performance per node than RDBMS
* Schema-less data model

### HBase:

Wide-column store based on Apache Hadoop and on concepts of BigTable.

Apache HBase is a NoSQL key/value store which runs on top of HDFS. Unlike Hive, HBase operations run in real-time on its database rather than MapReduce jobs. HBase is partitioned to tables, and tables are further split into column families. Column families, which must be declared in the schema, group together a certain set of columns (columns don’t require schema definition). For example, the "message" column family may include the columns: "to", "from", "date", "subject", and "body". Each key/value pair in HBase is defined as a cell, and each key consists of row-key, column family, column, and time-stamp. A row in HBase is a grouping of key/value mappings identified by the row-key. HBase enjoys Hadoop’s infrastructure and scales horizontally using off the shelf servers.

HBase works by storing data as key/value. It supports four primary operations: put to add or update rows, scan to retrieve a range of cells, get to return cells for a specified row, and delete to remove rows, columns or column versions from the table. Versioning is available so that previous values of the data can be fetched (the history can be deleted every now and then to clear space via HBase compactions). Although HBase includes tables, a schema is only required for tables and column families, but not for columns, and it includes increment/counter functionality.

HBase queries are written in a custom language that needs to be learned. SQL-like functionality can be achieved via Apache Phoenix, though it comes at the price of maintaining a schema. Furthermore, HBase isn’t fully ACID compliant, although it does support certain properties. Last but not least - in order to run HBase, ZooKeeper is required - a server for distributed coordination such as configuration, maintenance, and naming.

HBase is perfect for real-time querying of Big Data. Facebook use it for messaging and real-time analytics. They may even be using it to count Facebook likes.

Hbase has centralized architecture where The Master server is responsible for monitoring all RegionServer(responsible for serving and managing regions) instances in the cluster, and is the interface for all metadata changes. It provides CP(Consistency, Availability) form CAP theorem.

HBase is optimized for reads, supported by single-write master, and resulting strict consistency model, as well as use of Ordered Partitioning which supports row-scans. HBase is well suited for doing Range based scans.

Linear Scalability for large tables and range scans -
Due to Ordered Partitioning, HBase will easily scale horizontally while still supporting rowkey range scans.

Secondary Indexes - 
Hbase does not natively support secondary indexes, but one use-case of Triggers is that a trigger on a ""put"" can automatically keep a secondary index up-to-date, and therefore not put the burden on the application (client)."

Simple Aggregation- 
Hbase Co Processors support out-of-the-box simple aggregations in HBase. SUM, MIN, MAX, AVG, STD. Other aggregations can be built by defining java-classes to perform the aggregation

Real Usages: Facebook Messanger



