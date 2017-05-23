#!/bin/bash

function loadCSV {
  psql.py -t $1 localhost $2.csv
}

function log {
  echo ""
  echo "• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • "
  echo "`date` - LOG - $1 "
}

export HADOOP_PREFIX=/usr/local/hadoop
export ZOO_HOME=/usr/local/zookeeper
export HBASE_HOME=/usr/local/hbase
export JAVA_HOME=/usr/java/jdk1.7.0_71
export PHOENIX_HOME=/usr/local/phoenix
export PATH=$JAVA_HOME/bin:$PATH:$PHOENIX_HOME/bin

echo "Este shell Bash vai executar todo o Benchmark TPC-H. Digite SIM para continuar"
while read -e -t 1; do : ; done
read resp
if [ $resp. != 'SIM.' ]; then
    exit 0
fi

if [ $1. == 'DDL.' ]; then
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
    exit 0
fi

cd /spica/work
echo "Benchmark TP-H - HBase - João Antonio Ferreira e Raphael Abreu" > /spica/work/queries.log
sqlline.py localhost:2181 /spica/work/catalog.sql >> /spica/work/queries.log
rm -rf query-*.log queries.log
for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22
do
  echo "`date` - Executando Query $i"
  echo "`date` - Executando Query $i" >> /spica/work/queries.log
  time sqlline.py localhost:2181 /spica/work/dml-jsoares-$i.sql > /spica/work/query-$i.log
  head -n 10 /spica/work/query-$i.log
done
cat query-*.log > queries.log
echo "• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • "
for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22
do
  head -n 10 /spica/work/query-$i.log
done
# cat /spica/work/queries.log
/bin/bash
