# Format: FROM    repository[:version]
FROM ubuntu:16.04
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
# ui_port: "8082"
EXPOSE 8082
# nimbus_port: "6627"
EXPOSE 6627
# logviewer_port: "8083"
EXPOSE 8083
# drpc_port: "3772"
EXPOSE 3772
# monit
EXPOSE 3000

# make provision and start ....
ENTRYPOINT ["/provision/start.sh", "${type}"]
