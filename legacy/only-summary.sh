#!/bin/bash

function log {
  echo ""
  echo "• • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • "
  echo "`date` - LOG - $1 "
}

function filter {
  TOKENS=`awk 'BEGIN{OFS=" "}{print $1,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39}'`
  IFS=', ' read -r -a array <<< "$TOKENS"
  RESULT=""
  for element in "${array[@]}"
  do
    if [[ $element == *"bin/java"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"yarn.server.resourcemanager.ResourceManager"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"yarn.server.nodemanager.NodeManager"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"hadoop.hbase.master.HMaster"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"hadoop.hbase.regionserver.HRegionServer"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"zookeeper.server.quorum.QuorumPeerMain"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"hdfs.server.namenode.NameNode"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"hdfs.server.namenode.SecondaryNameNode"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"hadoop.hdfs.server.datanode.DataNode"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"phoenix.jdbc.PhoenixDriver"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"bin/sqlline.py"* ]]; then
      RESULT="$RESULT $element"
    fi
    if [[ $element == *"jsoares"* ]]; then
      RESULT="$RESULT $element"
    fi
  done
  if [ "$RESULT." != '.' ]; then
    echo $RESULT
  fi
}

while read LINE; do
  echo "$LINE" | filter
done
