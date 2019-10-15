#!/bin/bash

DATE_old=`date '+%Y-%m-%d-%H%M%S'`
DATE=`date '+%Y-%m-%d'`
echo $DATE

user_name=inr
git_repo_name=bluescope_fe
prodcode=buildcode

#wait=${1:-2}
#if [ $wait -eq 2 ] ;
#then
#  echo "Waiting for 2 minutes before running pipeline"
#  for i in `seq 18`;
#  do
#	  echo "Waiting for 10 seconds Loop: ${i}"
#	  sleep 10
#	  echo "Time completed $((i*10)) seconds"
#  done
#echo "Two minutes completed: and now starting the pendrive"
#else
#  echo "Hello"
#fi

#if [ -d /home/${user_name}/bluescope_fe ]
#then
#   if [ -f /home/${user_name}/bluescope_fe_backup/frontend_$DATE.tar.gz ] ;
#   then
#      mv /home/${user_name}/bluescope_fe_backup/frontend_$DATE.tar.gz /home/${user_name}/bluescope_fe_backup/frontend_$DATE_old.tar.gz
#    fi
    #CREATE A TAR FILE OF OLD CODE
#cd /home/${user_name}/Backup && tar -czvf frontend_$DATE.tar.gz /home/${user_name}/bluescope_fe
#if [ $? -eq 0 ]
#then
#	echo "tar file is created"
#	mv /home/${user_name}/Backup/frontend_$DATE.tar.gz /home/${user_name}/bluescope_fe_backup/
#	sleep 2
#else
#        echo "tar file is not created , Kindly check."
#        echo "Exiting from the script"
#        exit 0
#fi
#fi
if [ -d /home/${user_name}/bluescope_fe ] ;
then
   echo "Removing Contents of directory"
   rm -rf /home/${user_name}/bluescope_fe
   echo "Cloning git repository bluescope_fe"
   cd /home/${user_name} && git clone --branch release-test http://root:jgxTt!9sH^C3@192.168.7.178:8091/root/bluescope_fe.git
fi
#rm -rf /home/${user_name}/bluescope_fe
#if [ -d /home/${user_name}/target/frontend ]
#then
#	cd /home/${user_name}/target/frontend
#	git stash
#	git pull origin master
#	if [ -d /home/${user_name}/target/frontend/frontend/bluescope/dist ]
#	then
#		rm -rf /home/${user_name}/target/frontend/frontend/bluescope/dist
#	fi
#else 
#	cd /home/${user_name}/target
#	echo "Checking for cloning"
#	git clone git@gitlab.com:networkintelligence/${user_name}/bluescope/frontend.git
#	echo "cloning the bluescope_fe project"
#fi
#cd /home/${user_name}/target
#rm -f /home/${user_name}/target/${git_repo_name}/frontend/bluescope/proxy.conf.json
#cp /home/${user_name}/proxy.conf.json /home/${user_name}/target/${git_repo_name}/frontend/bluescope/
cd /home/${user_name}/${git_repo_name}/frontend/bluescope/
#npm install -g @angular/cli@7.0.2
npm install
if [ $? -eq 0 ]
then
	sleep 1
#	ng build
	npm run prod-build
#	gulp
	if [ $? -eq 0 ]
	then
		chown -R ${user_name}:${user_name} /home/${user_name}/${git_repo_name}/frontend/bluescope/dist/bluescope/*
		#cp -rf /home/${user_name}/target/frontend/frontend/bluescope/dist/bluescope/* /home/${user_name}/target/frontend
    if [ -d /home/${user_name}/${prodcode} ] ;
		then 
	      echo "Frontend folder already available"
        echo "Removing and making new code directory"
        rm -rf /home/${user_name}/${prodcode} && mkdir /home/${user_name}/${prodcode}
		    cp -rf /home/${user_name}/${git_repo_name}/frontend/bluescope/dist/bluescope/* /home/${user_name}/${prodcode}
		else
		    echo "Make a new directory /home/${user_name}/frontend/code"
		    mkdir /home/${user_name}/${prodcode}
		    cp -rf /home/${user_name}/${git_repo_name}/frontend/bluescope/dist/bluescope/* /home/${user_name}/${prodcode}
		fi
		      
		#		mv /home/${user_name}/bluescope /home/${user_name}/frontend_bluescope
		sleep 1
		echo "copies is done"
#		tar -czvf bluescope_fe_tar.gz /home/${user_name}/target/bluescope_fe
#		mv bluescope_fe_tar.gz /home/${user_name}/target/`
		
#		cp -rf /home/${user_name}/target/* /home/${user_name}
		chown -R ${user_name}:${user_name} /home/${user_name}/${prodcode}
		sleep 1
#		tar -zvxf /home/${user_name}/target/bluescope_fe_tar.gz -C /home/${user_name}/
		sleep 1
		sudo systemctl restart apache2
		echo "Deployment done"
	else
		echo "there is some problem in ng build command"
		exit 0
	fi
else
	echo "there is some problem in ng install commnad"
	exit 0
fi

