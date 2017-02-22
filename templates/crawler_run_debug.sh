#!/bin/sh
jar=libs/crawler*-all.jar
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000 -jar \${jar} server config/crawler_config.yml
