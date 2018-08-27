# Format: FROM    repository[:version]
FROM ubuntu:16.04
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
ADD artifacts artifacts/
ADD puppet_config puppet_config/
ADD modules modules/

RUN mkdir /data && mkdir /data/db && mkdir /data/logs
VOLUME ['/data/db']
VOLUME ['/data/logs']

# Expose ports
EXPOSE ${server_web_host_port}
EXPOSE ${server_web_ngnix_host_port}
# monit
EXPOSE 3000

# make provision and start ....
ENTRYPOINT ["/provision/start.sh", "${type}"]
