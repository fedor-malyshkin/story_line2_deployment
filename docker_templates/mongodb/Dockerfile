# Format: FROM    repository[:version]
FROM ubuntu:16.04
# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Fedor Malyshkin <fedor.malyshkin@yandex.ru>

# this path used by start.sh in ENTRYPOINT
WORKDIR /provision
# Installation:
COPY *.sh ./
ADD ${type} ${type}/
ADD puppet_config puppet_config/
ADD modules modules/

RUN mkdir /data && mkdir /data/db && mkdir /data/logs
VOLUME ['/data/db']
VOLUME ['/data/logs']

# Expose port  from the container to the host
EXPOSE 9200
# monit
EXPOSE 3000



# make provision and start ....
ENTRYPOINT ["/provision/start.sh", "${type}"]
