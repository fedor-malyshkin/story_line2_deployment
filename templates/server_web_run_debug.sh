#!/bin/sh
jar=libs/server_web*-all.jar
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000 -jar \${jar} server config/server_web_config.yml
