#!/bin/sh
docker-compose rm -f
docker-compose down --rmi all  --remove-orphans
docker rmi \$(docker images --all| grep '^stand' | awk '{print \$3}')
docker rmi \$(docker images --all| grep '^<none>' | awk '{print \$3}')


