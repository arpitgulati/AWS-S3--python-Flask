#!/bin/bash

DATE_old=`date '+%Y-%m-%d-%H%M%S'`
DATE=`date '+%Y-%m-%d'`

user_name=inr
git_repo_name=bluescope_be
server_ip=0.0.0.0

echo $DATE

#if [ -d /home/${user_name}/${git_repo_name} ]
#then
#   if [ -f /home/${user_name}/bluescope_be_backup/backend_$DATE.tar.gz ] ;
#   then
# mv /home/${user_name}/bluescope_be_backup/backend_$DATE.tar.gz /home/${user_name}/bluescope_be_backup/backend_$DATE_old.tar.gz
#   fi
  
#cd /home/${user_name}/Backup && tar -czvf backend_$DATE.tar.gz /home/${user_name}/${git_repo_name}
#if [ $? -eq 0 ]
#then
#	echo "tar file is created"
#	sudo mv /home/${user_name}/Backup/backend_$DATE.tar.gz /home/${user_name}/bluescope_be_backup
#	sleep 2
#else
#	echo "tar file is not created , Kindly check."
#	echo "Exiting from the script"
#	exit 0
#fi
#fi
pid=`ps -ef | grep python | grep "manage.py runserver ${server_ip}:8000" | grep -v grep | awk '{print $2}'`
  echo $pid 
  if [ -z "$pid" ]
    then
	      echo "manage.py(bluescope_backend) was not running before"
    else
        echo "killing manage.py"
        sudo kill -9 $pid 2>/dev/null 
          if [ $? -eq 0 ]
            then
		          echo "manage.py(bluescope_backend) and virtual environment is killed"
	          sleep 1
	        else
	            echo "unable to kill manage.py.Exiting from the script"
	       fi
  fi

check=`ps -ef | grep celery | grep -v grep  | grep -vw celery_report_worker | grep -vw celery_beat   |grep -vw celery_general_worker| awk '{print $2}'`
  echo $check
  if [ -z "$check" ]
  then
        echo "celery (bluescope_backend) was not running before"
  else
        echo "killing manage.py"
        sudo kill -9 $check 2>/dev/null
	if [ $? -eq 0 ]
        then
                echo "celery (bluescope_backend) and celery beat is killed"
                sleep 1
        else
                echo "unable to kill celery Exiting from the script"
        fi
fi
sleep 2
if [ -d /home/${user_name}/${git_repo_name} ]
then
  echo "Removing contents of /home/${user_name}/${git_repo_name} directory"
  rm -rf /home/${user_name}/${git_repo_name}
  echo "Creating new directory backend"
  cd /home/${user_name} && git clone --single-branch --branch release-v0.0.1 http://root:jgxTt!9sH^C3@192.168.7.178:8091/root/bluescope_be.git

fi		       
if [ $? -eq 0 ]
then
	echo "cloning is done"
	chown -R ${user_name}:${user_name} /home/${user_name}/${git_repo_name}
else
	echo "there is some problem in pulling , Kindly check"
	exit 0
fi

cd /home/${user_name}/${git_repo_name}/backend/bluescope
echo "installing dependencies for bluescope_be"
pipenv install Pipfile --skip-lock 
if [ $? -eq 0 ]
then
	echo "Dependencies have been installed successfully"
	echo "copying 0010_role.py to virtual envirnment directory"
	sudo cp /home/${user_name}/${git_repo_name}/backend/bluescope/0010_role.py /home/${user_name}/.local/share/virtualenvs/bluescope-*/lib/python3.6/site-packages/django/contrib/auth/migrations/
else
	echo "there is an error in installing dependencies"
	echo "Exiting from the script"
	exit 0
fi
echo "running migrate to install any changes in database schema"
#echo 'y' | pipenv run python manage.py makemigrations --merge 
cd /home/${user_name}/${git_repo_name}/backend/bluescope && pipenv run python manage.py migrate
pipenv run python manage.py runserver ${server_ip}:8000 >> /var/log/bluescope_backend.log 2>&1 &

if [ $? -eq 0 ]
then
	echo "migrate command run successfully"
	sleep 2
	echo "starting manage.py on server 0.0.0.0:8000"
	if [ $? -eq 0 ]
	then
		echo "manage.py is started successfully"
		echo "Deployment of stage_bluescope_backend is done and starting celery"
	else
		echo "there is some problem in starting manage.py , Kindly check the log file /var/log/bluescope_backend.log kept on 192.168.7.154"
		exit 0
	fi
fi
#tmp="tmp"
pipenv run celery -A bluescope worker --loglevel=info -Q report >> /home/inr/Logs/celery_report_worker.log 2>&1 &
if [ $? -eq 0 ]
then
	echo "celery worker for queue report is started"
	pipenv run celery -A bluescope worker --loglevel=info  >> /home/inr/Logs/celery_general_worker.log 2>&1 &
	if [ $? -eq 0 ]
	then
		echo "celery worker for general is started"
		pipenv run celery -A bluescope beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler >> /home/inr/Logs/celery_beat.log 2>&1 &
		if [ $? -eq 0 ]
		then
			echo "celery beat is started"
		else 
			echo "there is some promblem in starting celery beat kindly check log file /var/log/celery_beat.log"
			exit 0
		fi
	else
	
		echo "there is some error in starting celery general , Kindly check log  /var/log/celery_general_worker.log"
		exit 0
	fi
else
	echo "there is some error in starting celery reoprt , Kindly check log /var/log/celery_general_report.log"
	exit 0
fi
