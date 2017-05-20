FROM sequenceiq/hadoop-docker:2.7.0
MAINTAINER SequenceIQ

# zookeeper
ENV ZOOKEEPER_VERSION 3.4.6
RUN curl -s http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./zookeeper-$ZOOKEEPER_VERSION zookeeper
ENV ZOO_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOO_HOME/bin
RUN mv $ZOO_HOME/conf/zoo_sample.cfg $ZOO_HOME/conf/zoo.cfg
RUN mkdir /tmp/zookeeper

# hbase
ENV HBASE_MAJOR 1.1
ENV HBASE_MINOR 10
ENV HBASE_VERSION "${HBASE_MAJOR}.${HBASE_MINOR}"
RUN curl -s http://apache.mirror.gtcomm.net/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hbase-$HBASE_VERSION hbase
ENV HBASE_HOME /usr/local/hbase
ENV PATH $PATH:$HBASE_HOME/bin
RUN rm $HBASE_HOME/conf/hbase-site.xml
ADD hbase-site.xml $HBASE_HOME/conf/hbase-site.xml

# phoenix
ENV PHOENIX_VERSION 4.9.0
RUN curl -s http://apache.mirror.vexxhost.com/phoenix/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR/bin/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin.tar.gz | tar -xz -C /usr/local/
run ls -las /usr/local
RUN cd /usr/local && ln -s ./apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin phoenix

ENV PHOENIX_HOME /usr/local/phoenix
ENV PATH $PATH:$PHOENIX_HOME/bin
RUN cp /usr/local/phoenix/phoenix-core-$PHOENIX_VERSION-HBase-$HBASE_MAJOR.jar $HBASE_HOME/lib/phoenix.jar
RUN cp $PHOENIX_HOME/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-server.jar $HBASE_HOME/lib/phoenix-server.jar

# bootstrap-phoenix
ADD bootstrap-phoenix.sh /etc/bootstrap-phoenix.sh
RUN chown root:root /etc/bootstrap-phoenix.sh
RUN chmod 700 /etc/bootstrap-phoenix.sh

ENV JAVA_HOME /usr/java/jdk1.7.0_71
RUN echo "#" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo "# O HBase não lê do ambiente global. Temos de setar aqui o JAVA_HOME" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo "#" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo "export JAVA_HOME=/usr/java/jdk1.7.0_71" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo "#" >> /usr/local/hbase/conf/hbase-env.sh&& \
    echo "" >> /usr/local/hbase/conf/hbase-env.sh&& \
    cat /usr/local/hbase/conf/hbase-env.sh

# O comando abaixo deveria retirar o erro de binding na porta do ZooKeeper 
# quando usamos HBASE_MANAGES_ZK=false mas o que acontece e que passa a dar
# NullPointerException e o sqline para de funcionar.
# RUN echo "# HBase pode rodar sem seu proprio ZooKeeper" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "export HBASE_MANAGES_ZK=true" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "#" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "" >> /usr/local/hbase/conf/hbase-env.sh && \
#     cat /usr/local/hbase/conf/hbase-env.sh

RUN rm -rf /tmp/*

WORKDIR /spica/work

VOLUME /desenv

CMD ["/etc/bootstrap-phoenix.sh", "-bash"]

EXPOSE 8765
