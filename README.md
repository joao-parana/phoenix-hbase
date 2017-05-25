phoenix-hbase
=============

A Docker image to quick start [Apache Phoenix](http://phoenix.apache.org/) on [Apache HBase](https://hbase.apache.org/)
to provide an SQL interface.

Apache Phoenix is a SQL skin over HBase delivered as a client-embedded JDBC driver targeting low latency queries over HBase data.
Apache Phoenix takes your SQL query, compiles it into a series of HBase scans, and orchestrates the running of those scans to produce regular JDBC result sets.
The table metadata is stored in an HBase table and versioned, such that snapshot queries over prior versions will automatically use the correct schema.
Direct use of the HBase API, along with coprocessors and custom filters, results in performance on the order of milliseconds for small queries, or seconds for tens of millions of rows.

### Versions

* ZooKeeper 3.4.6
* Apache Hadoop - 2.7.1
* Apache HBase - 1.2.5
* Apache Phoenix - 4.10.0

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

#### Unsupported sql type: TEXT

```sql
CREATE TABLE CUSTOMER ( C_CUSTKEY INTEGER NOT NULL, C_NAME CHAR(25), C_ADDRESS VARCHAR(40), C_NATIONKEY INTEGER, C_PHONE CHAR(15), C_ACCTBAL DECIMAL(12,2), C_MKTSEGMENT VARCHAR(10), C_COMMENT text, CONSTRAINT CUSTUMER_PK PRIMARY KEY (C_CUSTKEY) );
```

```
Error: ERROR 201 (22000): Illegal data. **Unsupported sql type: TEXT** (state=22000,code=201)
```

Solution: Change TEXT to VARCHAR(9000):

```sql
CREATE TABLE CUSTOMER ( C_CUSTKEY INTEGER NOT NULL, C_NAME CHAR(25), C_ADDRESS VARCHAR(40), C_NATIONKEY INTEGER, C_PHONE CHAR(15), C_ACCTBAL DECIMAL(12,2), C_MKTSEGMENT VARCHAR(10), C_COMMENT VARCHAR(9000), CONSTRAINT CUSTUMER_PK PRIMARY KEY (C_CUSTKEY) );
```

Alguns problemas com Queries SQL

```sql
01 select l_returnflag, l_linestatus, sum(l_quantity) as sum_qty, sum(l_extendedprice) as sum_base_price, sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, avg(l_quantity) as avg_qty, avg(l_extendedprice) as avg_price, avg(l_discount) as avg_disc, count(*) as count_order from lineitem where l_shipdate <= date '1998-12-01' group by l_returnflag, l_linestatus order by l_returnflag, l_linestatus;
02 select s_acctbal, s_name, n_name, p_partkey, p_mfgr, s_address, s_phone, s_comment from part, supplier, partsupp, nation, region where p_partkey = ps_partkey and s_suppkey = ps_suppkey and p_size = 15 and p_type like '%PLATED%' and s_nationkey = n_nationkey and n_regionkey = r_regionkey and r_name = 'AMERICA' and ps_supplycost = ( select min(ps_supplycost) from partsupp, supplier, nation, region where p_partkey = ps_partkey and s_suppkey = ps_suppkey and s_nationkey = n_nationkey and n_regionkey = r_regionkey and r_name = 'AMERICA' ) order by s_acctbal desc, n_name, s_name, p_partkey;
03 select l_orderkey, sum(l_extendedprice * (1 - l_discount)) as revenue, o_orderdate, o_shippriority from customer, orders, lineitem where c_mktsegment = 'BUILDING' and c_custkey = o_custkey and l_orderkey = o_orderkey and o_orderdate < '1995-03-15' and l_shipdate > '1995-03-15' group by l_orderkey, o_orderdate, o_shippriority order by revenue desc, o_orderdate;
Error: ERROR 203 (22005): Type mismatch. TIMESTAMP and VARCHAR for O_ORDERDATE < '1995-03-15'

04 select o_orderpriority, count(*) as order_count from orders where o_orderdate >= '1995-03-15' and o_orderdate < '1995-06-15' and exists ( select * from lineitem where l_orderkey = o_orderkey and l_commitdate < l_receiptdate ) group by o_orderpriority order by o_orderpriority;
Error: ERROR 203 (22005): Type mismatch. TIMESTAMP and VARCHAR for O_ORDERDATE >= '1995-03-15'

05 select n_name, sum(l_extendedprice * (1 - l_discount)) as revenue from customer, orders, lineitem, supplier, nation, region where c_custkey = o_custkey and l_orderkey = o_orderkey and l_suppkey = s_suppkey and c_nationkey = s_nationkey and s_nationkey = n_nationkey and n_regionkey = r_regionkey and r_name = 'AMERICA' and o_orderdate >= '1995-03-15' and o_orderdate < '1996-03-15' group by n_name order by revenue desc;
Error: ERROR 203 (22005): Type mismatch. TIMESTAMP and VARCHAR for O_ORDERDATE >= '1995-03-15'

06 select sum(l_extendedprice * l_discount) as revenue from lineitem where l_shipdate >= date '1994-01-01' and l_shipdate < date '1995-01-01' + interval '1' year and l_discount between 0.05 - 0.01 and 0.05 + 0.01 and l_quantity < 25;
Error: ERROR 201 (22000): Illegal data. Unsupported sql type: INTERVAL 

07 select supp_nation, cust_nation, l_year, sum(volume) as revenue from ( select n1.n_name as supp_nation, n2.n_name as cust_nation, extract(year from l_shipdate) as l_year, l_extendedprice * (1 - l_discount) as volume from supplier, lineitem, orders, customer, nation n1, nation n2 where s_suppkey = l_suppkey and o_orderkey = l_orderkey and c_custkey = o_custkey and s_nationkey = n1.n_nationkey and c_nationkey = n2.n_nationkey and ( (n1.n_name = 'IRAN' and n2.n_name = 'UNITED STATES') or (n1.n_name = 'UNITED STATES' and n2.n_name = 'IRAN') ) and l_shipdate between date '1995-01-01' and date '1996-12-31' ) as shipping group by supp_nation, cust_nation, l_year order by supp_nation, cust_nation, l_year;
Error: ERROR 603 (42P00): Syntax error. Unexpected input. Expecting "LPAREN", got "extract" at line 1, column 131

08 select o_year, sum(case when nation = 'UNITED STATES' then volume else 0 end) / sum(volume) as mkt_share from ( select extract(year from o_orderdate) as o_year, l_extendedprice * (1 - l_discount) as volume, n2.n_name as nation from part, supplier, lineitem, orders, customer, nation n1, nation n2, region where p_partkey = l_partkey and s_suppkey = l_suppkey and l_orderkey = o_orderkey and o_custkey = c_custkey and c_nationkey = n1.n_nationkey and n1.n_regionkey = r_regionkey and r_name = 'AMERICA' and s_nationkey = n2.n_nationkey and o_orderdate between date '1995-01-01' and date '1996-12-31' and p_type = 'MEDIUM BRUSHED STEEL' ) as all_nations group by o_year order by o_year;
Error: ERROR 603 (42P00): Syntax error. Unexpected input. Expecting "LPAREN", got "extract" at line 1, column 120

09 select nation, o_year, sum(amount) as sum_profit from ( select n_name as nation, extract(year from o_orderdate) as o_year, l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity as amount from part, supplier, lineitem, partsupp, orders, nation where s_suppkey = l_suppkey and ps_suppkey = l_suppkey and ps_partkey = l_partkey and p_partkey = l_partkey and o_orderkey = l_orderkey and s_nationkey = n_nationkey and p_name like '%lime%' ) as profit group by nation, o_year order by nation, o_year desc;
Error: ERROR 603 (42P00): Syntax error. Unexpected input. Expecting "LPAREN", got "extract" at line 1, column 82.

10 select c_custkey, c_name, sum(l_extendedprice * (1 - l_discount)) as revenue, c_acctbal, n_name, c_address, c_phone, c_comment from customer, orders, lineitem, nation where c_custkey = o_custkey and l_orderkey = o_orderkey and o_orderdate >= date '1994-11-01' and o_orderdate < date '1994-11-01' + interval '3' month and l_returnflag = 'R' and c_nationkey = n_nationkey group by c_custkey, c_name, c_acctbal, c_phone, n_name, c_address, c_comment order by revenue desc;
Error: ERROR 201 (22000): Illegal data. Unsupported sql type: INTERVAL 

11 select ps_partkey, sum(ps_supplycost * ps_availqty) as value from partsupp, supplier, nation where ps_suppkey = s_suppkey and s_nationkey = n_nationkey and n_name = 'ARGENTINA' group by ps_partkey having sum(ps_supplycost * ps_availqty) > ( select sum(ps_supplycost * ps_availqty) * 0.0001000000 from partsupp, supplier, nation where ps_suppkey = s_suppkey and s_nationkey = n_nationkey and n_name = 'ARGENTINA' ) order by value desc;
Error: ERROR 604 (42P00): Syntax error. Mismatched input. Expecting "NAME", got "value" at line 1, column 56

12 select l_shipmode, sum(case when o_orderpriority = '1-URGENT' or o_orderpriority = '2-HIGH' then 1 else 0 end) as high_line_count, sum(case when o_orderpriority <> '1-URGENT' and o_orderpriority <> '2-HIGH' then 1 else 0 end) as low_line_count from orders, lineitem where o_orderkey = l_orderkey and l_shipmode in ('TRUCK', 'RAIL') and l_commitdate < l_receiptdate and l_shipdate < l_commitdate and l_receiptdate >= date '1994-01-01' and l_receiptdate < date '1994-01-01' + interval '1' year group by l_shipmode order by l_shipmode;
Error: ERROR 201 (22000): Illegal data. Unsupported sql type: INTERVAL 

13 select c_count, count(*) as custdist from ( select c_custkey, count(o_orderkey) from customer left outer join orders on c_custkey = o_custkey and o_comment not like '%pending%packages%' group by c_custkey ) as c_orders (c_custkey, c_count) group by c_count order by custdist desc, c_count desc;
Error: ERROR 602 (42P00): Syntax error. Missing "EOF" at line 1, column 220

14 select 100.00 * sum(case when p_type like 'PROMO%' then l_extendedprice * (1 - l_discount) else 0 end) / sum(l_extendedprice * (1 - l_discount)) as promo_revenue from lineitem, part where l_partkey = p_partkey and l_shipdate >= date '1994-03-01' and l_shipdate < date '1994-03-01' + interval '1' month;
Error: ERROR 201 (22000): Illegal data. Unsupported sql type: INTERVAL
```

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

##### Interactive mode

```bash
cd legacy
docker build -t parana/docker-phoenix-master .
docker save -o docker-phoenix-master.tar  parana/docker-phoenix-master:latest
scp -P 49133 docker-phoenix-master.tar  parana@my-remote-host:~/
```

```bash
# On my-remote-host I need to do:
docker load -i docker-phoenix-master.tar  -q
docker images
docker run -it --rm parana/docker-phoenix-master /etc/bootstrap-phoenix.sh -sqlline
```

##### Running Deamon mode

Start the container

```bash
docker run -d --name hbase -v $PWD/desenv:/desenv parana/docker-phoenix-master /etc/bootstrap-phoenix.sh -d
```

Enter on bash shell inside the container

```bash
docker exec -it hbase bash
```

Run SQL client CLI

```
/usr/local/phoenix/bin/sqlline.py localhost
```

Now you can paste SQL (DML or DDL) code, for example:

```sql
CREATE TABLE PART ( P_PARTKEY INTEGER NOT NULL, P_NAME VARCHAR(55), P_MFGR CHAR(25), P_BRAND CHAR(10), P_TYPE VARCHAR(25), P_SIZE INTEGER, P_CONTAINER CHAR(10), P_RETAILPRICE DECIMAL(12,2), P_COMMENT VARCHAR(23), CONSTRAINT PART_PK PRIMARY KEY (P_PARTKEY) );
CREATE TABLE SUPPLIER ( S_SUPPKEY INTEGER NOT NULL, S_NAME CHAR(25), S_ADDRESS VARCHAR(40), S_NATIONKEY INTEGER, S_PHONE CHAR(15), S_ACCTBAL DECIMAL(12,2), S_COMMENT VARCHAR(101), CONSTRAINT SUPPLIER_PK PRIMARY KEY (S_SUPPKEY) );
CREATE TABLE PARTSUPP ( PS_PARTKEY INTEGER NOT NULL, PS_SUPPKEY INTEGER NOT NULL, PS_AVAILQTY INTEGER, PS_SUPPLYCOST DECIMAL(12,2), PS_COMMENT VARCHAR(199), CONSTRAINT PARTSUPP_PK PRIMARY KEY (PS_PARTKEY, PS_SUPPKEY) );
CREATE TABLE CUSTOMER ( C_CUSTKEY INTEGER NOT NULL, C_NAME CHAR(25), C_ADDRESS VARCHAR(40), C_NATIONKEY INTEGER, C_PHONE CHAR(15), C_ACCTBAL DECIMAL(12,2), C_MKTSEGMENT VARCHAR(10), C_COMMENT VARCHAR(9000), CONSTRAINT CUSTUMER_PK PRIMARY KEY (C_CUSTKEY) );
CREATE TABLE ORDERS ( O_ORDERKEY INTEGER NOT NULL, O_CUSTKEY INTEGER, O_ORDERSTATUS CHAR(1), O_TOTALPRICE DECIMAL(12,2), O_ORDERDATE TIMESTAMP, O_ORDERPRIORITY CHAR(15), O_CLERK CHAR(15), O_SHIPPRIORITY INTEGER, O_COMMENT VARCHAR(9000), CONSTRAINT ORDERS_PK PRIMARY KEY (O_ORDERKEY) );
CREATE TABLE LINEITEM ( L_ORDERKEY INTEGER NOT NULL, L_PARTKEY INTEGER, L_SUPPKEY INTEGER, L_LINENUMBER INTEGER NOT NULL, L_QUANTITY DECIMAL(12,2), L_EXTENDEDPRICE DECIMAL(12,2), L_DISCOUNT DECIMAL(12,2), L_TAX DECIMAL(12,2), L_RETURNFLAG CHAR(1), L_LINESTATUS CHAR(1), L_SHIPDATE TIMESTAMP, L_COMMITDATE TIMESTAMP, L_RECEIPTDATE TIMESTAMP, L_SHIPINSTRUCT CHAR(25), L_SHIPMODE CHAR(10), L_COMMENT VARCHAR(9000), CONSTRAINT LINEITEM_PK PRIMARY KEY (L_ORDERKEY, L_LINENUMBER) );
CREATE TABLE NATION ( N_NATIONKEY INTEGER NOT NULL, N_NAME CHAR(25), N_REGIONKEY INTEGER, N_COMMENT VARCHAR(152), CONSTRAINT NATION_PK PRIMARY KEY (N_NATIONKEY) );
CREATE TABLE REGION ( R_REGIONKEY INTEGER NOT NULL, R_NAME CHAR(25), R_COMMENT VARCHAR(152), CONSTRAINT REGION_PK PRIMARY KEY (R_REGIONKEY) );
```

You can load CSV data to Database using:

```bash
psql.py -t PART localhost part.csv
psql.py -t SUPPLIER localhost supplier.csv
. . .
```
Or, if you define this bash shell

```bash
#!/bin/bash
set -e
function loadCSV {
  psql.py -t $1 localhost $2.csv
}
```

you can load using this:

```bash
  loadCSV PART     part
  loadCSV SUPPLIER supplier
  loadCSV PARTSUPP partsupp
  loadCSV CUSTOMER customer
  loadCSV ORDERS   orders
  loadCSV LINEITEM lineitem
  loadCSV NATION   nation
  loadCSV REGION   region
```

With the following bash code we run setup and all TPC-H queries 

```bash
if [[ $1 == "-sqlline" ]]; then
  log "Veja o tamanho do arquivo DDL"
  ls -la /spica/work/ddl-jsoares.sql
  sqlline.py localhost:2181 /spica/work/ddl-jsoares.sql
  cd /desenv/queries_novas
  loadCSV PART      part
  loadCSV SUPPLIER  supplier
  loadCSV PARTSUPP  partsupp
  loadCSV CUSTOMER  customer
  loadCSV ORDERS    orders
  loadCSV LINEITEM  lineitem
  loadCSV NATION    nation
  loadCSV REGION    region
  cd -
  echo "`date` - Benchmark TP-H - HBase - João Antonio Ferreira e Raphael Abreu" > /spica/work/queries.log
  sqlline.py localhost:2181 /spica/work/catalog.sql >> /spica/work/queries.log
  for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22
  do
    echo "`date` - Executando Query $i" >> /spica/work/queries.log
    time sqlline.py localhost:2181 /spica/work/dml-jsoares-$i.sql >> /spica/work/queries.log
  done
  echo "• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • "
  echo "`date` - Benchmark TP-H - End" > /spica/work/queries.log
  cat /spica/work/queries.log
  /bin/bash
fi
```

Where dml-jsoares-01.sql and dml-jsoares-02.sql is: 

```sql
select l_returnflag, l_linestatus, sum(l_quantity) as sum_qty, sum(l_extendedprice) as sum_base_price, sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, avg(l_quantity) as avg_qty, avg(l_extendedprice) as avg_price, avg(l_discount) as avg_disc, count(*) as count_order from lineitem where l_shipdate <= date '1998-12-01' group by l_returnflag, l_linestatus order by l_returnflag, l_linestatus;
select s_acctbal, s_name, n_name, p_partkey, p_mfgr, s_address, s_phone, s_comment from part, supplier, partsupp, nation, region where p_partkey = ps_partkey and s_suppkey = ps_suppkey and p_size = 15 and p_type like '%PLATED%' and s_nationkey = n_nationkey and n_regionkey = r_regionkey and r_name = 'AMERICA' and ps_supplycost = ( select min(ps_supplycost) from partsupp, supplier, nation, region where p_partkey = ps_partkey and s_suppkey = ps_suppkey and s_nationkey = n_nationkey and n_regionkey = r_regionkey and r_name = 'AMERICA' ) order by s_acctbal desc, n_name, s_name, p_partkey;
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

## Running on Ubuntu 16.04 64 bits

```bash
root@spica:/etc# : ${HADOOP_PREFIX:=/usr/local/hadoop}
root@spica:/etc# : ${ZOO_HOME:=/usr/local/zookeeper}
root@spica:/etc# : ${HBASE_HOME:=/usr/local/hbase}

root@spica:/etc# $HADOOP_PREFIX/sbin/start-dfs.sh
Starting namenodes on [spica.eic.cefet-rj.br]
spica.eic.cefet-rj.br: starting namenode, logging to /usr/local/hadoop/logs/hadoop-root-namenode-spica.out
200.9.149.138: starting datanode, logging to /usr/local/hadoop/logs/hadoop-root-datanode-spica.out
Starting secondary namenodes [0.0.0.0]
0.0.0.0: starting secondarynamenode, logging to /usr/local/hadoop/logs/hadoop-root-secondarynamenode-spica.out

root@spica:/etc# $HADOOP_PREFIX/sbin/start-yarn.sh
starting yarn daemons
starting resourcemanager, logging to /usr/local/hadoop/logs/yarn-root-resourcemanager-spica.out
200.9.149.138: starting nodemanager, logging to /usr/local/hadoop/logs/yarn-root-nodemanager-spica.out

root@spica:/etc# $ZOO_HOME/bin/zkServer.sh start
JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED

root@spica:/etc# $HBASE_HOME/bin/hbase version
2017-05-25 09:22:31,569 INFO  [main] util.VersionInfo: HBase 1.1.10
2017-05-25 09:22:31,570 INFO  [main] util.VersionInfo: Source code repository git://diocles.local/Volumes/hbase-1.1.10/hbase revision=af9719e45a1ee9f4509607aff7e554119d29e930
2017-05-25 09:22:31,570 INFO  [main] util.VersionInfo: Compiled by ndimiduk on Tue Apr 18 20:57:55 PDT 2017
2017-05-25 09:22:31,570 INFO  [main] util.VersionInfo: From source with checksum ca073185cac889588a4de74d92d49b56

root@spica:/etc# $HBASE_HOME/bin/start-hbase.sh
localhost: starting zookeeper, logging to /usr/local/hbase/bin/../logs/hbase-root-zookeeper-spica.out
localhost: java.net.BindException: Address already in use
localhost:  at sun.nio.ch.Net.bind0(Native Method)
localhost:  at sun.nio.ch.Net.bind(Net.java:433)
localhost:  at sun.nio.ch.Net.bind(Net.java:425)
localhost:  at sun.nio.ch.ServerSocketChannelImpl.bind(ServerSocketChannelImpl.java:223)
localhost:  at sun.nio.ch.ServerSocketAdaptor.bind(ServerSocketAdaptor.java:74)
localhost:  at sun.nio.ch.ServerSocketAdaptor.bind(ServerSocketAdaptor.java:67)
localhost:  at org.apache.zookeeper.server.NIOServerCnxnFactory.configure(NIOServerCnxnFactory.java:95)
localhost:  at org.apache.zookeeper.server.ZooKeeperServerMain.runFromConfig(ZooKeeperServerMain.java:111)
localhost:  at org.apache.hadoop.hbase.zookeeper.HQuorumPeer.runZKServer(HQuorumPeer.java:94)
starting master, logging to /usr/local/hbase/logs/hbase-root-master-spica.out
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
starting regionserver, logging to /usr/local/hbase/logs/hbase-root-1-regionserver-spica.out

root@spica:/etc# show-hbase-processes.sh 
sshd|hbase|hadoop|zookeeper|java|phoenix.jdbc.PhoenixDriver|bin/sqlline.py|soares sshd|hbase|hadoop|zookeeper|java|phoenix.jdbc.PhoenixDriver|bin/sqlline.py|soares
/usr/lib/jvm/java-8-oracle/bin/java org.apache.hadoop.hbase.master.HMaster
/usr/lib/jvm/java-8-oracle/bin/java org.apache.hadoop.hbase.regionserver.HRegionServer
/usr/lib/jvm/java-8-oracle/bin/java org.apache.hadoop.hdfs.server.datanode.DataNode
/usr/lib/jvm/java-8-oracle/bin/java org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode
/usr/lib/jvm/java-8-oracle/bin/java org.apache.hadoop.yarn.server.nodemanager.NodeManager
/usr/lib/jvm/java-8-oracle/bin/java org.apache.hadoop.yarn.server.resourcemanager.ResourceManager
/usr/lib/jvm/java-8-oracle/bin/java org.apache.zookeeper.server.quorum.QuorumPeerMain
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



