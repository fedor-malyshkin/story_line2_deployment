#!/bin/sh
# Файл, запускаемый monit
COMMAND=supervisor
# flag-file to run supervisor in debug mode
FILE=/server_storm/debug

STORM_BIN_DIR="/server_storm/apache-storm-${server_storm_version}/bin"
ADD_OPTS=""

if [ -f \$FILE ]; then
   ADD_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000"
fi

\${STORM_BIN_DIR}/storm \${COMMAND}  \${ADD_OPTS} 2>&1 1> \${STORM_BIN_DIR}/\${COMMAND}.log &
echo \$! > \${STORM_BIN_DIR}/storm_\${COMMAND}.pid
