#!/bin/bash

function loadCSV {
  psql.py -t $1 localhost $2.csv
}

function log {
  echo ""
  echo "• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • "
  echo "`date` - LOG - $1 "
}

log "Iniciando o HBase"

export HADOOP_PREFIX=/usr/local/hadoop
export ZOO_HOME=/usr/local/zookeeper
export HBASE_HOME=/usr/local/hbase
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export PHOENIX_HOME=/usr/local/phoenix
export PATH=$JAVA_HOME/bin:$PATH:$PHOENIX_HOME/bin

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

ps -ef | grep sshd
log "Verificando os processos"
ps -ef | grep -E --color=auto -i "sshd|hbase|hadoop|zookeeper|java"
echo "Verifique que os processos NÃO estão rodando ? Digite SIM para continuar"
while read -e -t 1; do : ; done
read resp
if [ $resp. != 'SIM.' ]; then
    exit 0
fi
# service sshd start
log "Iniciando o Hadoop / HDFS"
$HADOOP_PREFIX/sbin/start-dfs.sh
log "Iniciando o YARN"
$HADOOP_PREFIX/sbin/start-yarn.sh
log "Iniciando o ZooKeeper"
$ZOO_HOME/bin/zkServer.sh start
log "Iniciando o HBASE"
$HBASE_HOME/bin/start-hbase.sh
log "`date` - Checando as versões"
$HADOOP_PREFIX/bin/hadoop version
$ZOO_HOME/bin/zkServer.sh status
$HBASE_HOME/bin/hbase version

env

log "Veja o tamanho do arquivo DDL"
ls -la /spica/work/ddl-jsoares.sql

log "Verificando os processos"
ps -ef | grep -E --color=auto -i "sshd|hbase|hadoop|zookeeper|java"
echo "Verifique se os processos estão rodando. Digite SIM para continuar"
while read -e -t 1; do : ; done
read resp
if [ $resp. != 'SIM.' ]; then
    exit 0
fi

if [ $1 = 'DDL' ]; then
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
