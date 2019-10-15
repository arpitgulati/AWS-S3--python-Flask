#!/bin/bash

DATE_old=`date '+%Y-%m-%d-%H%M%S'`
DATE=`date '+%Y-%m-%d'`

user_name=inr
server_ip=0.0.0.0
#if [ -d /home/${user_name}/ruleio ] 
#then
#  if [ -f /home/${user_name}/ruleio_backup/ruleio_$DATE.tar.gz ] 
#    then
#      mv /home/${user_name}/ruleio_backup/ruleio_$DATE.tar.gz /home/${user_name}/ruleio_backup/ruleio_$DATE_old.tar.gz
#    fi
#    cd /home/${user_name}/Backup && tar -czvf ruleio_$DATE.tar.gz /home/${user_name}/ruleio
#    if [ $? -eq 0 ] 
#    then
#	    echo "tar file is created"
#	    mv /home/${user_name}/Backup/ruleio_$DATE.tar.gz /home/${user_name}/ruleio_backup/
#	  sleep 2
#    else
#        echo "tar file is not created , Kindly check."
#        echo "Exiting from the script"
#    fi
#fi

pid=`ps -ef | grep "manage.py runserver ${server_ip}:8001" | grep -v grep  | awk '{print $2}'`
if [ -z "$pid" ] ;
  then
	    echo "ruleio worker was not running"
  else
	    kill -9 $pid
	    echo "ruleio worker is killed"
fi

if [ -d /home/${user_name}/ruleio ] ;
then
	echo "Deleting the ruleio directory"
        rm -rf /home/${user_name}/ruleio
	echo "Cloning the ruleio project"
	cd /home/${user_name} && git clone --branch release-test http://root:jgxTt!9sH^C3@192.168.7.178:8091/bluescope/ruleio.git 
fi

if [ $? -eq 0 ] ;
then
        echo "cloning is done"
else
        echo "there is some problem in cloning , Kindly check"
        exit 0
fi
sudo chown -R ${user_name}:${user_name} /home/${user_name}/ruleio
cd /home/${user_name}/ruleio && pipenv install Pipfile --skip-lock
if [ $? -eq 0 ] ;
then
	echo "Dependencies have been installed successfully"
        cd /home/${user_name}/ruleio && pipenv run python manage.py runserver ${server_ip}:8001 >> /home/inr/Logs/ruleio.log 2>&1 &
else
        echo "there is an error in installing dependencies"
        echo "Exiting from the script"
        exit 0
fi
if [ $? -eq 0 ] ;
then
        echo "ruleio worker is started"
else
        echo "there is an error in starting ruleio worker , Kindly check log file /var/log/rulesio.log"
        echo "Exiting from the script"
fi

