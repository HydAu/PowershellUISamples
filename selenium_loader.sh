#!/bin/bash 
CONFIG_FILE=${1:-jsTestDriver.conf}
Xvfb :1000 -ac >/dev/null 2>&1 &
XSERVER_PID=$!
export DISPLAY=:1000
LISTENING_PROCESS_ID=$(sudo netstat -nap | grep 5555 | awk '{print $7}'| grep '/java'|head -1 | sed 's/\/.*$//')
if [ "$LISTENING_PROCESS_ID" != "" ] ; then
echo killing java $LISTENING_PROCESS_ID

kill -HUP $LISTENING_PROCESS_ID
echo killing all java processes by commandline
sudo ps ax -opid,comm,args |  grep java |  grep 5555  2>/dev/null| tail -1 | awk  '{print $1}' | xargs echo kill -HUP
sleep 1
echo killing firefoxes
ps ax -opid,comm | grep firef | tail -1 | awk '{print $1}' | xargs echo kill -HUP
sleep 1
fi
# exit 0 

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
echo  starting browser
java -Xms1024M -Xmx1024M -jar selenium-server-standalone.jar -role node -hub http://192.168.0.9:4444/hub/register &
lsof -b -i TCP
MY_RUNNERMODE=DEBUG
MY_RUNNERMODE=QUIET
sleep 10
echo Press Enter to terminate
read stop
# TODO: pass profile
{
kill -QUIT $XSERVER_PID
}  > /dev/null 2>&1
# ps -p $(cat $(uname -n):1.pid)
# kill -TERM $(cat $(uname -n):1.pid)
