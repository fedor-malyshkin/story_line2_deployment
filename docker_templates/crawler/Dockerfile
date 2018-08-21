# Format: FROM    repository[:version]
FROM ubuntu:18.04
# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Fedor Malyshkin <fedor.malyshkin@yandex.ru>

# this path used by start.sh in ENTRYPOINT
WORKDIR /provision
# Installation:
COPY *.sh ./
ADD ${type} ${type}/
ADD crawler_scripts crawler_scripts/
ADD artifacts artifacts/
ADD puppet_config puppet_config/
ADD modules modules/

RUN mkdir /data && mkdir /data/db && mkdir /data/logs
VOLUME ['/data/db']
VOLUME ['/data/logs']

# Expose port  from the container to the host
EXPOSE ${crawler_host_port}
# monit
EXPOSE 3000
# java debug port
EXPOSE ${crawler_java_debug_host_port}
# java jmx port
EXPOSE ${crawler_java_jmx_host_port}

# make provision and start ....
ENTRYPOINT ["/provision/start.sh", "${type}"]
