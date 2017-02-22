# Format: FROM    repository[:version]
FROM       openjdk:8-jdk
# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Fedor Malyshkin <fedor.malyshkin@yandex.ru>

WORKDIR /server_storm
# Installation:
RUN apt-get update && apt-get install -y wget puppet htop python monit
# Prepare by Puppet
COPY server_storm.pp .
RUN puppet apply server_storm.pp

WORKDIR /server_storm
RUN wget -nv --tries=3 http://apache-mirror.rbc.ru/pub/apache/storm/apache-storm-${server_storm_version}/apache-storm-${server_storm_version}.tar.gz \
&& tar x --gunzip -f apache-storm-${server_storm_version}.tar.gz && cd apache-storm-${server_storm_version}

VOLUME ['/data/db']
VOLUME ['/data/logs']

# Prepare by Script
COPY storm.yaml apache-storm-${server_storm_version}/conf/
COPY server_storm_config.yaml /data/db
COPY run_*.sh apache-storm-${server_storm_version}/bin/
COPY monitrc /etc/

# for ports look - http://storm.apache.org/releases/1.0.2/SECURITY.html
EXPOSE ${server_storm_ui_cont_port ?: 8080}
EXPOSE ${server_storm_logviewer_cont_port ?: 8000}
EXPOSE ${server_storm_nimbus_cont_port ?: 6627}
EXPOSE ${server_storm_monit_cont_port ?: 2812}

#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["apache-storm-${server_storm_version}/bin/run_services.sh"]
