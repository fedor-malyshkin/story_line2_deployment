#!/bin/sh
# Файл, запускаемый как ENTITYPOINT в Dockere или локально для запуска в режиме отладки
STORM_BIN_DIR="/server_storm/apache-storm-${server_storm_version}/bin"
\${STORM_BIN_DIR}/run_storm_nimbus.sh
sleep 5
\${STORM_BIN_DIR}/run_storm_drpc.sh
sleep 5
\${STORM_BIN_DIR}/run_storm_supervisor.sh
sleep 5
\${STORM_BIN_DIR}/run_storm_ui.sh
sleep 2
\${STORM_BIN_DIR}/run_storm_logviewer.sh
sleep 2
#Запустить monit без перехода в режим демона
monit -I
