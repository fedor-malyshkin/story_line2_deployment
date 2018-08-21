# Format: FROM    repository[:version]
FROM ubuntu:18.04
# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Fedor Malyshkin <fedor.malyshkin@yandex.ru>

# this path used by start.sh in ENTRYPOINT
WORKDIR /provision
# Installation:
COPY *.sh ./
ADD ${type} ${type}/
ADD artifacts artifacts/
ADD puppet_config puppet_config/
ADD modules modules/

RUN mkdir /data && mkdir /data/db && mkdir /data/logs
VOLUME ['/data/db']
VOLUME ['/data/logs']

# Expose ports
EXPOSE ${spark_master_port}
EXPOSE ${spark_master_webui_port}
EXPOSE ${spark_worker_port}
EXPOSE ${spark_worker_webui_port}
# monit
EXPOSE 3000

# make provision and start ....
ENTRYPOINT ["/provision/start.sh", "${type}"]
