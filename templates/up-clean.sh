#!/bin/sh
docker-compose build --force-rm
docker-compose up -d --force-recreate  --build

