#!/bin/bash

# | : ${HADOOP_PREFIX:=/usr/local/hadoop}
# | : ${ZOO_HOME:=/usr/local/zookeeper}
# | : ${HBASE_HOME:=/usr/local/hbase}

rm -rf /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# | Tentativa frustrada | export HADOOP_CLASSPATH=`$HBASE_HOME/bin/hbase classpath`

service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$ZOO_HOME/bin/zkServer.sh start
# nohup /usr/java/jdk1.7.0_71/bin/java -Dzookeeper.log.dir=. -Dzookeeper.root.logger=INFO,CONSOLE -cp '/usr/local/zookeeper/bin/../build/classes:/usr/local/zookeeper/bin/../build/lib/*.jar:/usr/local/zookeeper/bin/../lib/slf4j-log4j12-1.6.1.jar:/usr/local/zookeeper/bin/../lib/slf4j-api-1.6.1.jar:/usr/local/zookeeper/bin/../lib/netty-3.7.0.Final.jar:/usr/local/zookeeper/bin/../lib/log4j-1.2.16.jar:/usr/local/zookeeper/bin/../lib/jline-0.9.94.jar:/usr/local/zookeeper/bin/../zookeeper-3.4.6.jar:/usr/local/zookeeper/bin/../src/java/lib/*.jar:/usr/local/zookeeper/bin/../conf:' -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false org.apache.zookeeper.server.quorum.QuorumPeerMain /usr/local/zookeeper/bin/../conf/zoo.cfg
# ZooKeeper na porta 2181
$HBASE_HOME/bin/start-hbase.sh

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

if [[ $1 == "-sqlline" ]]; then
  /usr/local/phoenix/bin/sqlline.py localhost
fi
