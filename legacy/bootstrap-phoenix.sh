#!/bin/bash

function loadCSV {
  psql.py -t $1 localhost $2.csv
}

function log {
  echo "`date` - LOG - $1 "
}

log "Iniciando o HBase"

: ${HADOOP_PREFIX:=/usr/local/hadoop}
: ${ZOO_HOME:=/usr/local/zookeeper}
: ${HBASE_HOME:=/usr/local/hbase}

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$ZOO_HOME/bin/zkServer.sh start
$HBASE_HOME/bin/start-hbase.sh

echo "`date` - Checando as versões"
$HADOOP_PREFIX/bin/hadoop version
$ZOO_HOME/bin/zkServer.sh status
$HBASE_HOME/bin/hbase version

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

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
  echo "Benchmark TP-H - HBase - João Antonio Ferreira e Raphael Abreu" > /spica/work/queries.log
  sqlline.py localhost:2181 /spica/work/catalog.sql >> /spica/work/queries.log
  for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22
  do
    echo "`date` - Executando Query $i" >> /spica/work/queries.log
    time sqlline.py localhost:2181 /spica/work/dml-jsoares-$i.sql >> /spica/work/queries.log
  done
  echo "• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • "
  cat /spica/work/queries.log
  /bin/bash
fi
