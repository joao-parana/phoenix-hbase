#FROM sequenceiq/hadoop-docker:2.7.3

FROM postgres:9.6.2

MAINTAINER João Paraná

RUN apt-get update && apt-get install -y curl wget 

# zookeeper
ENV ZOOKEEPER_VERSION 3.4.6
RUN curl -s http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./zookeeper-$ZOOKEEPER_VERSION zookeeper
ENV ZOO_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOO_HOME/bin
RUN mv $ZOO_HOME/conf/zoo_sample.cfg $ZOO_HOME/conf/zoo.cfg
RUN mkdir /tmp/zookeeper

# hbase
ENV HBASE_MAJOR 1.2
ENV HBASE_MINOR 5
ENV HBASE_VERSION "${HBASE_MAJOR}.${HBASE_MINOR}"

COPY install /tmp

# Instalando o Apache Phoenix
RUN cd /tmp/apache-phoenix-4.10.0-HBase-1.2-bin_tar_gz && \
    cat xaa xab xac xad xae xaf > ../apache-phoenix-4.10.0-HBase-1.2-bin.tar.gz && \
    rm -rf xaa xab xac xad xae xaf

RUN echo "Vou fazer: tar -xzf /tmp/apache-phoenix-4.10.0-HBase-1.2-bin.tar.gz"  

RUN cd /usr/local/hbase && \
    tar -xzf /tmp/apache-phoenix-4.10.0-HBase-1.2-bin.tar.gz && \
    ls -lat . && \
    mv apache-phoenix-4.10.0-HBase-1.2-bin phoenix-hbase-jdbc && \
    ls -lat phoenix-hbase-jdbc

#   |  RUN curl -s http://apache.mirror.gtcomm.net/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz | tar -xz -C /usr/local/
#   |  RUN cd /usr/local && ln -s ./hbase-$HBASE_VERSION hbase
#   |  ENV HBASE_HOME /usr/local/hbase
#   |  ENV PATH $PATH:$HBASE_HOME/bin
#   |  RUN rm $HBASE_HOME/conf/hbase-site.xml
#   |  ADD hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
#   |  
#   |  # phoenix
#   |  ENV PHOENIX_VERSION 4.6.0
#   |  RUN curl -s http://apache.mirror.vexxhost.com/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR/bin/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin.tar.gz | tar -xz -C /usr/local/
#   |  RUN cd /usr/local && ln -s ./phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin phoenix
#   |  ENV PHOENIX_HOME /usr/local/phoenix
#   |  ENV PATH $PATH:$PHOENIX_HOME/bin
#   |  RUN cp $PHOENIX_HOME/phoenix-core-$PHOENIX_VERSION-HBase-$HBASE_MAJOR.jar $HBASE_HOME/lib/phoenix.jar
#   |  RUN cp $PHOENIX_HOME/phoenix-server-$PHOENIX_VERSION-HBase-$HBASE_MAJOR.jar $HBASE_HOME/lib/phoenix-server.jar
#   |  
#   |  # bootstrap-phoenix
#   |  ADD bootstrap-phoenix.sh /etc/bootstrap-phoenix.sh
#   |  RUN chown root:root /etc/bootstrap-phoenix.sh
#   |  RUN chmod 700 /etc/bootstrap-phoenix.sh
#   |  
#   |  CMD ["/etc/bootstrap-phoenix.sh", "-bash"]
#   |  

EXPOSE 8765
