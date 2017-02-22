#!/bin/sh
# Конвертировать конфигурации в локальные (для запуска и отладки - не в контейнере)
DIR=apache-storm-${server_storm_version}

if [ ! -d \$DIR ]; then
    wget -nv --tries=3 http://apache-mirror.rbc.ru/pub/apache/storm/apache-storm-${server_storm_version}/apache-storm-${server_storm_version}.tar.gz
    tar x --gunzip -f apache-storm-${server_storm_version}.tar.gz
fi

CWD=`pwd`
# escape variable
CWD=`echo \$CWD | sed 's/\\//\\\\\\\\\\//g'`
sed -i "s/\\/server_storm/\${CWD}/g" run_*.sh monitrc
sed -i "s/\\/var\\/log/\${CWD}/g"  monitrc

DATADIR="${data_dir}/server_storm"
# escape variable
DATADIR=`echo \$DATADIR | sed 's/\\//\\\\\\\\\\//g'`
sed -i "s/\\/data\\/db/\${DATADIR}/g"   storm.yaml

# change "zookeeper" name to "localhost"
sed -i 's/"zookeeper"/"localhost"/g'   storm.yaml

cp storm.yaml apache-storm-${server_storm_version}/conf
cp run_storm*.sh apache-storm-${server_storm_version}/bin
