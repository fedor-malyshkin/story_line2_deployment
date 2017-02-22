# Format: FROM    repository[:version]
FROM       openjdk:8-jdk
# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Fedor Malyshkin <fedor.malyshkin@yandex.ru>

WORKDIR /elasticsearch
# Installation:
RUN apt-get update && apt-get install -y wget puppet htop
# Prepare by Puppet
COPY elasticsearch.pp .
RUN puppet apply elasticsearch.pp

USER 'elastic'
WORKDIR /elasticsearch
RUN wget -nv --tries=3 https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${elasticsearch_version}.tar.gz \
&& tar x --gunzip -f elasticsearch-${elasticsearch_version}.tar.gz && cd elasticsearch-${elasticsearch_version}

# Prepare by Script
COPY elasticsearch.yml elasticsearch-${elasticsearch_version}/config
COPY logging.yml elasticsearch-${elasticsearch_version}/config

VOLUME ['/data/db']
VOLUME ['/data/logs']

# Expose port ${elasticsearch_cont_port ?: 9200} from the container to the host
EXPOSE ${elasticsearch_cont_port ?: 9200}


ENTRYPOINT ["elasticsearch-${elasticsearch_version}/bin/elasticsearch"]
