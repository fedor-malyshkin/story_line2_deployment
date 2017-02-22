#!/bin/sh
# Файл, запускаемый monit
COMMAND=logviewer
STORM_BIN_DIR="/server_storm/apache-storm-${server_storm_version}/bin"
\${STORM_BIN_DIR}/storm \${COMMAND}  2>&1 1> \${STORM_BIN_DIR}/\${COMMAND}.log &
echo \$! > \${STORM_BIN_DIR}/storm_\${COMMAND}.pid
