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
