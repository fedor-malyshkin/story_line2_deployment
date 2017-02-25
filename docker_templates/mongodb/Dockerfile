# Format: FROM    repository[:version]
FROM       ubuntu:xenial
# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Fedor Malyshkin <fedor.malyshkin@yandex.ru>

WORKDIR /mongodb
# Installation:
# Update apt-get sources AND install MongoDB
RUN apt-get update && apt-get install -y mongodb puppet htop

# Prepare by Puppet
COPY mongodb.pp .
RUN puppet apply mongodb.pp

USER mongo
WORKDIR /mongodb

VOLUME ['/data/db']
VOLUME ['/data/logs']

# Expose port ${mongodb_cont_port} from the container to the host
EXPOSE ${mongodb_cont_port ?: 27017}

# Set usr/bin/mongod as the dockerized entry-point application
ENTRYPOINT ["/usr/bin/mongod", "--port", "${mongodb_cont_port ?: 27017}", "--logpath=/data/logs/mongodb.log"]
