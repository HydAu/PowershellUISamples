#!/bin/sh
# set -x
set -e
SELENIUM_USER='root'
SELENIUM_HOME='/root/selenium'
SERVICE_NAME='selenium'
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DEFAULTS="/etc/default/${SERVICE_NAME}"
INITSCRIPT="$(basename "$0")"
JOB="${INITSCRIPT%.sh}"
PIDFILE='/var/run/hub.pid'
LOGFILE_DIR='var/log'
PIDFILE_DIR='/var/run'
COMMAND="$1"

export NODE_PORT=5555
export HUB_IP_ADDRESS=127.0.0.1
export HUB_PORT=4444
export SELENIUM_JAR_VERSION=2.44.0 # currently unused
export DISPLAY_PORT=99
export ROLE=node

# TODO: process when JAVA_HOME not set 
SELENIUM_ARGS=`cat<<EEE
-classpath \
$SELENIUM_HOME/log4j-1.2.17.jar:$SELENIUM_HOME/selenium-server-standalone.jar: \
-Dlog4j.configuration=node.log4j.properties \
org.openqa.grid.selenium.GridLauncher \
-role node \
-host $NODE_HOST \
-port $NODE_PORT \
-hub http://${HUB_IP_ADDRESS}:${HUB_PORT}/hub/register \
-nodeConfig $NODE_CONFIG  \
-browserTimeout 12000 -timeout 12000 \
-ensureCleanSession true \
-trustAllSSLCertificates
EEE
`
echo $SELENIUM_ARGS
