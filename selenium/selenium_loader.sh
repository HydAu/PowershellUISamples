#!/bin/bash 
CONFIG_FILE=${1:-jsTestDriver.conf}
Xvfb :1000 -ac >/dev/null 2>&1 &
SELENIUM_NODE_PID=$!
export DISPLAY=:1000
# export DISPLAY=:1
# VNC is a better option if one needs to see the display
# TODO - investigate
# http://theseekersquill.wordpress.com/2010/03/16/vnc-server-ubuntu-windows/
# http://stevenharman.net/blog/archive/2008/12/13/vnc-to-a-headless-ubuntu-box.aspx
RUNNING_PID=$(sudo netstat -npl | grep 5555 | awk '{print $7}'| grep '/java'|head -1 | sed 's/\/.*$//')
if [ "$RUNNING_PID" != "" ] ; then
echo killing java $RUNNING_PID
kill -1 $RUNNING_PID
sudo ps ax -opid,comm,args |  grep java |  grep 5555  2>/dev/null| tail -1 | awk  '{print $1}' | xargs echo kill -1 
sleep 1
echo killing firefoxes
ps ax -opid,comm | grep firef | tail -1 | awk '{print $1}' | xargs echo kill -1
sleep 1
fi

PROFILE=$(grep -Eio 'Path=(.*)' ~/.mozilla/firefox/profiles.ini)
echo "Clearing firefox history in default profile $PROFILE"

{
rm ~/.mozilla/firefox/$PROFILE/cookies.txt
rm ~/.mozilla/firefox/$PROFILE/Cache/*
rm ~/.mozilla/firefox/$PROFILE/downloads.rdf
rm ~/.mozilla/firefox/$PROFILE/history.dat
}  > /dev/null 2>&1
sleep 3
echo setting java environment
export JAVA_HOME=/opt/jre1.6.0_31/
export PATH=$PATH:$JAVA_HOME/bin
export PATH=$PATH:/opt/firefox
echo Starting browser
export HUB_IP_ADDRESS=192.168.0.9
export HUB_IP_ADDRESS=127.0.0.1
java -Xms1024M -Xmx1024M -jar selenium-server-standalone.jar -role node -hub http://${HUB_IP_ADDRESS}:4444/hub/register &
SELENIUM_NODE_PID=$!
#
lsof -b -i TCP
MY_RUNNERMODE=DEBUG
MY_RUNNERMODE=QUIET
sleep 10
echo Press Enter to terminate
read stop
# TODO: pass profile
{
kill -HUP $SELENIUM_NODE_PID
sleep 120
kill -QUIT $SELENIUM_NODE_PID
}  > /dev/null 2>&1
# ps -p $(cat $(uname -n):1.pid)
# kill -TERM $(cat $(uname -n):1.pid)
