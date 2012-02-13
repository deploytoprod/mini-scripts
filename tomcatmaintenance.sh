#!/bin/sh
# ABOUT: this is a script to maintenance tomcat services
# AUTHOR: Rafael Lopes
# CREATED AT: 20120213
# CURRENT VERSION: 1.1

# CHANGELOG
# 1.1 - mispell fixes and more verbose scp function
# 1.0 - initial release

#DO NOT TOUCH THOSE VARIABLES. DO NOT COMMENT THEM. NEVER!!
LOGDIR=/usr/tomcat/apache-tomcat-7.0.21/logs
WEBAPPSDIR=/usr/tomcat/apache-tomcat-7.0.21/webapps
REMOTEADDR=`echo $SSH_CLIENT |cut -d ' ' -f 1`
REMOTEFILE=/root/placeholder/deployfile

checkDirExists(){
       if [ ! -d "$1" ]; then
               echo -e "\033[31mERROR: the folder $1 does not exists. Exiting now...\033[0m"
               exit 2
       fi
}
banner(){
       num=`echo -n \`hostname\` |wc -m`
       for ((i=0; i<$num; ++i ));
       do
               echo -n "_"
       done
       echo -e "\n\033[2m`hostname`\033[0m\n"
}
listFiles(){
       checkDirExists $1
       echo -e "Files to be removed:"
       du -csh $1/*
}
checkAndKillJps(){
       checkJpsProcess
       jpsstatus=$?
       if [ $jpsstatus -eq 0 ]; then
               echo -e "\033[31mtomcat (pid $pid) is running, let me stop it...\033[0m"
               service tomcat stop
               return 1;
       else
               echo -e "\033[32mtomcat is stopped...\033[0m"
               return 0;
       fi
}
checkJpsProcess(){ #retorna 0 caso vivo e 1 caso morto
       pid="$(/usr/bin/pgrep -d , -u root -G root java)"
       if [ -z "$pid" ]; then
               return 1;
       else
               return 0;
       fi
}
waitUntilJpsHalted(){
       checkAndKillJps
       jpsexitcode=$?
       while [[ $jpsexitcode -ne 0 ]]
       do
               sleep 7
               checkAndKillJps
               jpsexitcode=$?
       done
       #now i can say jps is dead
}
removeFiles(){
       checkDirExists $1
       rm -fv $1/*
       echo -en "\033[32mDirectory $1 now empty.\033[0m\n"
}
startTomcat(){
       checkJpsProcess
       jpsstatus=$?
       if [ $jpsstatus -eq 0 ]; then
               echo -e "\033[31mtomcat (pid $pid) is already running, if you want to start anyway, I suggest stop it first...\033[0m"
               return 1;
       else
               echo -e "\033[32mStarting tomcat...\033[0m"
               sleep 2
               service tomcat start
               echo -ne "\033[32m"
               sleep 1
               service tomcat status
               echo -ne "\033[0m"
               return 0;
       fi
}
getFileViaSCP(){
       echo -e "\033[32mAttempting to get $2 from $1 and REPLACE into $3...\033[0m"
       scp $1:$2 $3
       scpexitcode=$?
       if [ $scpexitcode -ne 0 ]; then
               echo -e "\033[31mError on SCP transfer\033[0m"
               return 1
       else
               sleep 1
               echo -e "\033[32mSCP OK! Remote file $2 placed in $3 directory on `hostname`\033[0m"
       fi
}
printUsage(){
       echo -en "\n\033[35mtomcatmaintenance v1.0\033[0m usage methods:\n\n"
       echo -e "start\t\tChecks if tomcat is started, it not, start it"
       echo -e "stop\t\tChecks if tomcat is stopped, it not, stop it"
       echo -e "status\t\tPrints the tomcat status"
       echo -e "restart\t\tStops tomcat if not stopped, clean the logs and start it again (use with care)"
       echo -e "deploy\t\tDo the same as restart, but also clean webapps folder and put a new file on it"
       echo
}

case $1 in
       [Ss][Tt][Aa][Rr][Tt] )
               banner
               startTomcat
               echo; exit;;
       [Ss][Tt][Oo][Pp] )
               banner
               waitUntilJpsHalted
               listFiles $LOGDIR
               echo
               removeFiles $LOGDIR
               echo
               echo -e "\033[35mtomcat stopped and logs cleaned on `hostname`. Thank you for your attention.\033[0m"
               exit;;
       [Ss][Tt][Aa][Tt][Uu][Ss] )
               banner
               service tomcat status
               echo; exit;;
       [Rr][Ee][Ss][Tt][Aa][Rr][Tt] )
               banner
               waitUntilJpsHalted
               listFiles $LOGDIR
               echo
               removeFiles $LOGDIR
               echo
               startTomcat
               echo
               echo -e "\033[35mRestart process finished on `hostname`. Thank you for your attention.\033[0m"
               exit;;
       [Dd][Ee][Pp][Ll][Oo][Yy] )
               banner
               waitUntilJpsHalted
               echo
               listFiles $LOGDIR
               echo
               removeFiles $LOGDIR
               echo
               listFiles $WEBAPPSDIR
               echo
               removeFiles $WEBAPPSDIR
               echo
               getFileViaSCP $REMOTEADDR $REMOTEFILE $WEBAPPSDIR
               echo
               startTomcat
               echo
               echo -e "\033[35mDeploy process finished on `hostname`. Thank you for your attention.\033[0m"
               exit;;
       * )
               printUsage
               exit 1;;
esac