#!/bin/bash
SCRIPTS_HOME="/root/"
TOMCAT_LOCATION="/opt/apache-tomcat-7.0.70/"
PROCESSID_TEMP="processid_temp"
JAVA_HOME=/usr/java/jdk1.7.0_79/jre
LOG_FILE=`"$SCRIPTS_HOME"/restart_log.txt`
cd /opt/apache-tomcat-7.0.70/      
bash bin/shutdown.sh 
ps -ef | grep "$TOMCAT_LOCATION" | grep -v grep | awk '{print $2}' > $SCRIPTS_HOME/$PROCESSID_TEMP
if [ -s $SCRIPTS_HOME/$PROCESSID_TEMP ]
then
for PROCESSID in `cat $SCRIPTS_HOME/$PROCESSID_TEMP`
do
echo -e "\nMaking sure the process is stopped properly by checking with the process id $PROCESSID\n"
COUNT=`ps -ef | grep $PROCESSID | grep -v grep | wc -l`
if [ $COUNT != 0 ]
then
echo -e "Tomcat process is not stopped. Killing the same forcefully\n"
kill -9 $PROCESSID
sleep 3
else
echo -e "Tomcat is stopped properly\n" >> $LOG_FILE
fi
done
else
echo -e "Tomcat is not running\n"  >> $LOG_FILE
fi

