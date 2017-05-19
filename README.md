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
docker save -o docker-phoenix-master.tar  parana/docker-phoenix-master:latest
scp -P 49133 docker-phoenix-master.tar  parana@my-remote-host:~/
# On my-remote-host I need to do:
docker load -i docker-phoenix-master.tar  -q
docker images
```

#### Testing

```sql
CREATE TABLE IF NOT EXISTS us_population (
      state CHAR(2) NOT NULL,
      city VARCHAR NOT NULL,
      population BIGINT
      CONSTRAINT my_pk PRIMARY KEY (state, city));

UPSERT into us_population (state, city, population) values ('CA','Los Angeles',3844829);
UPSERT into us_population (state, city, population) values ('NY','New York',8143197);

SELECT state as "State",count(city) as "City Count",sum(population) as "Population Sum"
FROM us_population
GROUP BY state
ORDER BY sum(population) DESC;



NY,New York,8143197
CA,Los Angeles,3844829
IL,Chicago,2842518
TX,Houston,2016582
PA,Philadelphia,1463281
AZ,Phoenix,1461575
TX,San Antonio,1256509
CA,San Diego,1255540
TX,Dallas,1213825
CA,San Jose,912332
```
