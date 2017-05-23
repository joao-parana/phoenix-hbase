FROM sequenceiq/hadoop-docker:2.7.1
# TODO: Atualizar pra Java 8, usando Ubuntu 16.04  da imagem parana/hadoop
# FROM parana/hadoop

MAINTAINER joao.parana@gmail.com

# Baseado na Imagem da sequenceiq. Troquei de CentOS para Ubuntu 16.04 e troquei a versão do Java.

# Copiando os binários para evitar sucessivos downloads
COPY install /tmp

# Instalando o ZooKeeper
ENV ZOOKEEPER_VERSION 3.4.6
# RUN curl -s http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xz -C /usr/local/
RUN mkdir -p /usr/local/ && \
    cd /usr/local/ && \
    tar -xzf /tmp/zookeeper-$ZOOKEEPER_VERSION.tar.gz && \
    mv zookeeper-$ZOOKEEPER_VERSION zookeeper

# Configurando o ZooKeeper     
# RUN cd /usr/local && ln -s ./zookeeper-$ZOOKEEPER_VERSION zookeeper
ENV ZOO_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOO_HOME/bin
RUN mv $ZOO_HOME/conf/zoo_sample.cfg $ZOO_HOME/conf/zoo.cfg
RUN mkdir /tmp/zookeeper

# Ambiente HBase
ENV HBASE_MAJOR 1.2
ENV HBASE_MINOR 5
ENV HBASE_VERSION "${HBASE_MAJOR}.${HBASE_MINOR}"

# Instalando o HBase
RUN cd /tmp/hbase-1.2.5-bin_tar_gz && \
    cat xaa xab xac > ../hbase-1.2.5-bin.tar.gz && \
    rm -rf xaa xab xac

RUN echo "Vou fazer: tar -xzf /tmp/hbase-1.2.5-bin.tar.gz"  

RUN cd /usr/local && \
    tar -xzf /tmp/hbase-1.2.5-bin.tar.gz && \
    ls -lat . && \
    mv hbase-1.2.5 hbase && \
    ls -lat hbase

RUN cd /usr/local/hbase && \
    cat conf/hbase-site.xml

# Instalando o Apache Phoenix
RUN cd /tmp/apache-phoenix-4.10.0-HBase-1.2-bin_tar_gz && \
    cat xaa xab xac xad xae xaf > ../apache-phoenix-4.10.0-HBase-1.2-bin.tar.gz && \
    rm -rf xaa xab xac xad xae xaf

RUN echo "Vou fazer: tar -xzf /tmp/apache-phoenix-4.10.0-HBase-1.2-bin.tar.gz"  

RUN mkdir -p /usr/local && \
    cd /usr/local && \
    tar -xzf /tmp/apache-phoenix-4.10.0-HBase-1.2-bin.tar.gz && \
    ls -lat . && \
    mv apache-phoenix-4.10.0-HBase-1.2-bin phoenix && \
    ls -lat phoenix

# Configurando o HBase
ENV HBASE_HOME /usr/local/hbase
ENV PATH $PATH:$HBASE_HOME/bin
RUN ls -lat /usr/local
RUN ls -lat $HBASE_HOME
RUN ls -lat $HBASE_HOME/conf
RUN mv $HBASE_HOME/conf/hbase-site.xml /tmp/hbase-site.xml-original
ADD hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
RUN diff $HBASE_HOME/conf/hbase-site.xml /tmp/hbase-site.xml-original ; /bin/true

# Configurando o Apache Phoenix
ENV PHOENIX_VERSION 4.10.0
ENV PHOENIX_HOME /usr/local/phoenix
ENV PATH $PATH:$PHOENIX_HOME/bin
RUN cp /usr/local/phoenix/phoenix-core-$PHOENIX_VERSION-HBase-$HBASE_MAJOR.jar $HBASE_HOME/lib/phoenix.jar
RUN cp $PHOENIX_HOME/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-server.jar $HBASE_HOME/lib/phoenix-server.jar
ENV PATH $PATH:$PHOENIX_HOME/bin
# Assim poderemos invocar o comando abaixo no contêiner para acessar o HBase via Phoenix
# sqlline.py localhost

# bootstrap-phoenix
ADD bootstrap-phoenix.sh /etc/bootstrap-phoenix.sh
RUN chown root:root /etc/bootstrap-phoenix.sh
RUN chmod 777 /etc/bootstrap-phoenix.sh

RUN yum install -y python-argparse.noarch

# TODO: Atualizar pra Java 8
ENV JAVA_HOME /usr/java/jdk1.7.0_71
RUN echo "#" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo "# O HBase não lê do ambiente global. Temos de setar aqui o JAVA_HOME" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo "#" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo "export JAVA_HOME=/usr/java/jdk1.7.0_71" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo "#" >> /usr/local/hbase/conf/hbase-env.sh && \
    echo " " >> /usr/local/hbase/conf/hbase-env.sh

# O comando abaixo deveria retirar o erro de binding na porta do ZooKeeper
# RUN echo "# HBase pode rodar sem seu proprio ZooKeeper" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "export HBASE_MANAGES_ZK=false" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "#" >> /usr/local/hbase/conf/hbase-env.sh && \
#     echo "" >> /usr/local/hbase/conf/hbase-env.sh

# RUN rm -rf /tmp/*

WORKDIR /spica/work

VOLUME /desenv

# RUN ENV HADOOP_CLASSPATH `$HBASE_HOME/bin/hbase classpath`
EXPOSE 8765

RUN echo "`date` - ATENÇÃO: é importante verificar se todas a svariáveis JAVA_HOME estão corretas" &&\
    find / -type f -exec grep JAVA_HOME {} \; && \
    find /etc -type f -exec grep JAVA_HOME {} \;

CMD ["/etc/bootstrap-phoenix.sh", "-bash"]


