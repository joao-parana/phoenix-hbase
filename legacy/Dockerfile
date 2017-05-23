FROM sequenceiq/hadoop-docker:2.7.0

MAINTAINER joao.parana@gmail.com

# | # Estas variáveis são definidas também no Dockerfile do qual herdo.
# | ENV JAVA_HOME /usr/java/default
# | ENV PATH $PATH:$JAVA_HOME/bin
# | ENV HADOOP_PREFIX /usr/local/hadoop
# | ENV HADOOP_COMMON_HOME /usr/local/hadoop
# | ENV HADOOP_HDFS_HOME /usr/local/hadoop
# | ENV HADOOP_MAPRED_HOME /usr/local/hadoop
# | ENV HADOOP_YARN_HOME /usr/local/hadoop
# | ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
# | ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

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
RUN mv $HBASE_HOME/conf/hbase-site.xml /tmp/hbase-site.xml-original
ADD hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
RUN diff $HBASE_HOME/conf/hbase-site.xml /tmp/hbase-site.xml-original ; /bin/true

# phoenix
ENV PHOENIX_VERSION 4.9.0
RUN curl -s http://apache.mirror.vexxhost.com/phoenix/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR/bin/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin.tar.gz | tar -xz -C /usr/local/
run ls -las /usr/local
RUN cd /usr/local && ln -s ./apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin phoenix

ENV PHOENIX_HOME /usr/local/phoenix
ENV PATH $PATH:$PHOENIX_HOME/bin
RUN cp /usr/local/phoenix/phoenix-core-$PHOENIX_VERSION-HBase-$HBASE_MAJOR.jar $HBASE_HOME/lib/phoenix.jar
RUN cp $PHOENIX_HOME/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-server.jar $HBASE_HOME/lib/phoenix-server.jar
ENV PATH $PATH:$PHOENIX_HOME/bin
# Assim poderemos invocar o comando abaixo no contêiner para acessar o HBase via Phoenix
# sqlline.py localhost

WORKDIR /spica/work

# bootstrap-phoenix
RUN ls -lat /etc
ADD bootstrap-phoenix.sh /etc/bootstrap-phoenix.sh
ADD do-benchmark.sh      /etc/do-benchmark.sh
ADD start-hbase.sh       /etc/start-hbase.sh
ADD only-summary.sh      /etc/only-summary.sh
ADD ddl-jsoares.sql      /spica/work/ddl-jsoares.sql
ADD dml-jsoares-*.sql    /spica/work/
ADD catalog.sql          /spica/work/catalog.sql
RUN chown root:root /etc/bootstrap-phoenix.sh
RUN chmod 777 /etc/bootstrap-phoenix.sh


ENV JAVA_HOME /usr/java/jdk1.7.0_71
RUN echo "#" >> $HBASE_HOME/conf/hbase-env.sh && \
    echo "# O HBase não lê do ambiente global. Temos de setar aqui o JAVA_HOME" >> $HBASE_HOME/conf/hbase-env.sh && \
    echo "#" >> $HBASE_HOME/conf/hbase-env.sh && \
    echo "export JAVA_HOME=/usr/java/jdk1.7.0_71" >> $HBASE_HOME/conf/hbase-env.sh && \
    echo "#" >> $HBASE_HOME/conf/hbase-env.sh&& \
    echo "" >> $HBASE_HOME/conf/hbase-env.sh&& \
    cat $HBASE_HOME/conf/hbase-env.sh

RUN echo "# O Hadoop não lê do ambiente global. Temos de setar aqui o JAVA_HOME" >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    echo "#" >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    echo "export JAVA_HOME=/usr/java/jdk1.7.0_71" >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    echo "#" >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    echo "" >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    cat $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# O comando abaixo deveria retirar o erro de binding na porta do ZooKeeper 
# quando usamos HBASE_MANAGES_ZK=false mas o que acontece e que passa a dar
# NullPointerException e o sqline para de funcionar.
# RUN echo "# HBase pode rodar sem seu proprio ZooKeeper" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "export HBASE_MANAGES_ZK=true" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "#" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "" >> /usr/local/hbase/conf/hbase-env.sh && \
#     cat /usr/local/hbase/conf/hbase-env.sh

# RUN rm -rf /tmp/*

VOLUME /desenv

EXPOSE 8765
EXPOSE 2181

# RUN echo "`date` - ATENÇÃO: é importante verificar se todas as variáveis JAVA_HOME estão corretas" && \
#     find /usr/local -type f -exec grep "JAVA_HOME=" {} \;     && \
#     find /etc -type f -exec grep "JAVA_HOME=" {} \;           && \
#     find /usr/local -type f -exec grep -l "JAVA_HOME=" {} \;  && \
#     find /etc -type f -exec grep -l "JAVA_HOME=" {} \; && \
#     find . -type f -exec grep -l jdk1.8.0  {} \;
# 
# RUN for a in `echo "/usr/local/hbase-1.1.10/bin/hbase-daemon.sh /usr/local/hbase-1.1.10/conf/hbase-env.sh /usr/local/apache-phoenix-4.9.0-HBase-1.1-bin/bin/config/env.sh /usr/local/zookeeper-3.4.6/src/packages/update-zookeeper-env.sh /usr/local/zookeeper-3.4.6/src/packages/templates/conf/zookeeper-env.sh /usr/local/hadoop-2.7.0/bin/rcc /usr/local/hadoop-2.7.0/bin/yarn /usr/local/hadoop-2.7.0/etc/hadoop/yarn-env.sh /usr/local/hadoop-2.7.0/etc/hadoop/hadoop-env.sh /usr/local/hadoop-2.7.0/etc/hadoop/mapred-env.sh /usr/local/hadoop-2.7.0/share/hadoop/kms/tomcat/bin/setclasspath.sh /usr/local/hadoop-2.7.0/share/hadoop/kms/tomcat/bin/tool-wrapper.sh /usr/local/hadoop-2.7.0/share/hadoop/kms/tomcat/bin/daemon.sh /usr/local/hadoop-2.7.0/share/hadoop/kms/tomcat/bin/catalina.sh /usr/local/hadoop-2.7.0/share/hadoop/httpfs/tomcat/bin/setclasspath.sh /usr/local/hadoop-2.7.0/share/hadoop/httpfs/tomcat/bin/tool-wrapper.sh /usr/local/hadoop-2.7.0/share/hadoop/httpfs/tomcat/bin/daemon.sh /usr/local/hadoop-2.7.0/share/hadoop/httpfs/tomcat/bin/catalina.sh /usr/local/hadoop-2.7.0/libexec/hadoop-config.sh /etc/start-hbase.sh /etc/do-benchmark.sh"` 
# RUN  cat /usr/local/hbase-1.1.10/bin/hbase-daemon.sh /usr/local/hbase-1.1.10/conf/hbase-env.sh /usr/local/apache-phoenix-4.9.0-HBase-1.1-bin/bin/config/env.sh /usr/local/zookeeper-3.4.6/src/packages/update-zookeeper-env.sh /usr/local/zookeeper-3.4.6/src/packages/templates/conf/zookeeper-env.sh /usr/local/hadoop-2.7.0/bin/rcc /usr/local/hadoop-2.7.0/bin/yarn /usr/local/hadoop-2.7.0/etc/hadoop/yarn-env.sh /usr/local/hadoop-2.7.0/etc/hadoop/hadoop-env.sh /usr/local/hadoop-2.7.0/etc/hadoop/mapred-env.sh /usr/local/hadoop-2.7.0/share/hadoop/kms/tomcat/bin/setclasspath.sh /usr/local/hadoop-2.7.0/share/hadoop/kms/tomcat/bin/tool-wrapper.sh /usr/local/hadoop-2.7.0/share/hadoop/kms/tomcat/bin/daemon.sh /usr/local/hadoop-2.7.0/share/hadoop/kms/tomcat/bin/catalina.sh /usr/local/hadoop-2.7.0/share/hadoop/httpfs/tomcat/bin/setclasspath.sh /usr/local/hadoop-2.7.0/share/hadoop/httpfs/tomcat/bin/tool-wrapper.sh /usr/local/hadoop-2.7.0/share/hadoop/httpfs/tomcat/bin/daemon.sh /usr/local/hadoop-2.7.0/share/hadoop/httpfs/tomcat/bin/catalina.sh /usr/local/hadoop-2.7.0/libexec/hadoop-config.sh /etc/start-hbase.sh /etc/do-benchmark.sh | grep "JAVA_HOME="

RUN for a in `find /usr/local/hadoop-2.7.0 -type f -exec grep -l "JAVA_HOME=" {} \;` ; do    echo $a ;   grep "JAVA_HOME=" $a ; done
RUN for a in `find /etc -type f -exec grep -l "JAVA_HOME=" {} \;` ; do    echo $a ;   grep "JAVA_HOME=" $a ; done

CMD ["/etc/bootstrap-phoenix.sh", "-bash"]
