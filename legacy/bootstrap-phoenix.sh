#!/bin/bash

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
  /usr/local/phoenix/bin/sqlline.py localhost
  /bin/bash
fi
