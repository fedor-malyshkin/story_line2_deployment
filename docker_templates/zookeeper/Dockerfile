# Format: FROM    repository[:version]
FROM       openjdk:8-jdk
# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Fedor Malyshkin <fedor.malyshkin@yandex.ru>

WORKDIR /zookeeper
# Installation:
RUN apt-get update && apt-get install -y wget puppet htop
# Prepare by Puppet
COPY zookeeper.pp .
RUN puppet apply zookeeper.pp

USER zoo
WORKDIR /zookeeper
RUN wget -nv --tries=3 http://apache-mirror.rbc.ru/pub/apache/zookeeper/zookeeper-${zookeeper_version}/zookeeper-${zookeeper_version}.tar.gz \
&& tar x --gunzip -f zookeeper-${zookeeper_version}.tar.gz && cd zookeeper-${zookeeper_version}

# Prepare by Script
COPY zoo.cfg zookeeper-${zookeeper_version}/conf
COPY log4j.properties zookeeper-${zookeeper_version}/conf

VOLUME ['/data/db']
VOLUME ['/data/logs']

# Expose port 2181 from the container to the host
EXPOSE 2181
#
ENTRYPOINT ["zookeeper-${zookeeper_version}/bin/zkServer.sh", "start-foreground"]
