#!/bin/bash
PROCESSID_TEMP="processid_temp"
JAVA_HOME=/usr/java/jdk1.7.0_79/jre
LOG_FILE="/tmp/log`date +%F`
bash /opt/apache-tomcat-7.0.70/bin/startup.sh
CHECK_TOMCAT=`ps -ef | grep java | awk -F'-Dcatalina.base=/opt/' '{print $2}' | awk '{ print $1 }' | wc -l`

if [ $CHECK_TOMCAT != 0 ]
then
echo -e "Tomcat is started properly\n" >> $LOG_FILE
else
echo -e "Tomcat is not started properly\n" >> $LOG_FILE
fi
