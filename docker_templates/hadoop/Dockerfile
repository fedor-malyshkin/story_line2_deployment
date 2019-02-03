# Format: FROM    repository[:version]
FROM ubuntu:18.04
# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Fedor Malyshkin <fedor.malyshkin@yandex.ru>

# this path used by start.sh in ENTRYPOINT
WORKDIR /provision
# Installation:
COPY *.sh ./
# see https://github.com/gdraheim/docker-systemctl-replacement
COPY systemctl.py /bin/systemctl
RUN chmod 777 /bin/systemctl

ADD ${type} ${type}/
ADD puppet_config puppet_config/
ADD modules modules/

RUN mkdir /data && mkdir /data/db && mkdir /data/logs
VOLUME ['/data/db']
VOLUME ['/data/logs']

# Expose ports
EXPOSE ${hadoop_namenode_web_port}
EXPOSE ${hadoop_namenode_meta_port}
EXPOSE ${hadoop_datanode_web_port}
EXPOSE ${hadoop_datanode_data_port}
EXPOSE ${hadoop_datanode_meta_port}

# monit
EXPOSE 3000

# make provision and start ....
ENTRYPOINT ["/provision/start.sh", "${type}"]
