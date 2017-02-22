#!/bin/sh
jar=libs/server_web*-all.jar
java -jar \${jar} server config/server_web_config.yml
