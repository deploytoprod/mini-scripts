#!/bin/sh -
# ABOUT: A script to maintenance tomcat services
# AUTHOR: Rafael Lopes
# CREATED AT: 201202131700
# LAST MODIFIED: 201202231124
# CURRENT VERSION: 1.3.1

# CHANGELOG
# 1.3.1 - sets x.x.x.x as scp master
# 1.3 - adds rollback support and implements maxtry to kill java
# 1.2 - backups current File.war file on deploy method
# 1.1 - mispell fixes and more verbose scp function
# 1.0 - initial release

#DO NOT TOUCH THOSE VARIABLES. DO NOT COMMENT THEM. NEVER!!
LOGDIR=/usr/tomcat/apache-tomcat-7.0.21/logs
WEBAPPSDIR=/usr/tomcat/apache-tomcat-7.0.21/webapps
BACKUPDIR=/tmp/Deploy-Backups
REMOTEADDR=x.x.x.x
REMOTEFILE=/root/placeholder/File.war
MAXTRY=3
NOW=`date +"%Y%m%d%H%M%S"`

checkDirExists(){
       if [ ! -d "$1" ]; then
               echo -e "\033[31mERROR: the folder '$1' does not exists. Exiting now...\033[0m"
               exit 2
       fi
}
banner(){
       num=`echo -n \`hostname\` |wc -m`
       for ((i=0; i<$num; ++i ));
       do
               echo -en "\033[35m-"
       done
       echo
       echo `hostname`
       for ((i=0; i<$num; ++i ));
       do
               echo -en "\033[35m-"
       done
       echo -e "\033[0m"
       echo
}
listFiles(){
       checkDirExists $1
       echo -e "Files to be removed:"
       du -csh $1/*
}
checkAndKillJps(){
       checkJpsProcess
       jpsstatus=$?
       if [ $jpsstatus -ne 0 ]; then
               echo -e "\033[31mtomcat (pid $pid) is running, let me stop it...\033[0m"
               service tomcat stop
               return 1;
       else
               echo -e "\033[32mtomcat is stopped...\033[0m"
               return 0;
       fi
}
checkJpsProcess(){ #Returns pid if alive and 0 if dead
       pid="$(/usr/bin/pgrep -d , -u root -G root java)"
       if [ -z "$pid" ]; then
               return 0;
       else
               return $pid;
       fi
}
killJpsByPid(){
       # Hasta la vista, Jps...
       checkJpsProcess
       jpsstatus=$?
       if [ $jpsstatus -ne 0 ]; then
               echo -e "\033[31mStopping tomcat (pid $pid) via kill method...\033[0m"
               kill -9 $pid
               return 1;
       else
               echo -e "\033[32mtomcat is stopped...\033[0m"
               return 0;
       fi
}
waitUntilJpsHalted(){
       try=0
       checkAndKillJps
       jpsexitcode=$?
       while [[ $jpsexitcode -ne 0 ]]
       do
               sleep 7
               checkAndKillJps
               jpsexitcode=$?
               if [ $try -ge $MAXTRY ]; then
                       killJpsByPid
               fi
               try=`expr $try + 1`
       done
       #now I can safely say jps is dead
}
removeFiles(){
       checkDirExists $1
       rm -Rfv $1/*
       echo -en "\033[32mDirectory '$1' now empty.\033[0m\n"
}
startTomcat(){
       checkJpsProcess
       jpsstatus=$?
       if [ $jpsstatus -ne 0 ]; then
               echo -e "\033[31mtomcat (pid $pid) is already running, if you want to start anyway, I suggest stop it first...\033[0m"
               return 1;
       else
               echo -e "\033[32mStarting tomcat...\033[0m"
               service tomcat start
               sleep 2
               echo -ne "\033[32m"
               service tomcat status
               echo -ne "\033[0m"
               return 0;
       fi
}
getFileViaSCP(){
       echo -e "\033[32mAttempting to get '$2' from '$1' and REPLACE into '$3'...\033[0m"
       scp $1:$2 $3
       scpexitcode=$?
       if [ $scpexitcode -ne 0 ]; then
               echo -e "\033[31mError on SCP transfer\033[0m"
               exit 1
       else
               sleep 1
               echo -e "\033[32mSCP OK! Remote file '$2' placed in '$3' directory on '`hostname`'\033[0m"
       fi
}
printUsage(){
       echo -en "\n\033[35mtomcatmaintenance v1.3\033[0m usage methods:\n\n"
       echo -e "start\t\tChecks if tomcat is started, it not, start it"
       echo -e "stop\t\tChecks if tomcat is stopped, it not, stop it"
       echo -e "status\t\tPrints the tomcat status"
       echo -e "restart\t\tStops tomcat if not stopped, clean the logs and start it again (use with care)"
       echo -e "deploy\t\tDo the same as restart, but also clean webapps folder and put a new File.war file on it (use with care)"
       echo -e "rollback\tDo the inverse as deploy. Clean logs and webapps folder but, reverts File.war file from current backup (use with care)"
       echo
}
makeBackup(){
       echo -e "\033[32mCreating directory '$BACKUPDIR/$NOW'...\033[0m"
       mkdir -p $BACKUPDIR/$NOW/
       mkdirexitcode=$?
       if [ $mkdirexitcode -ne 0 ]; then
               echo -e "\033[31mError on directory '$BACKUPDIR/$NOW' creation. Check permissions and everything else.\033[0m"
               return 1
       fi
       echo -e "\033[32mBacking up '$1' to '$BACKUPDIR/$NOW'...\033[0m"
       cp -v $1 $BACKUPDIR/$NOW/
       cpexitcode=$?
       if [ $cpexitcode -ne 0 ]; then
               echo -e "\033[31mError on file copy! Check if '$1' contents exists on '$BACKUPDIR/$NOW/' folder.\033[0m"
               return 2
       fi
       #all done, lets simbolic to latest path...
       rm -f $BACKUPDIR/latest
       ln -s $BACKUPDIR/$NOW $BACKUPDIR/latest
}
restoreBackup(){
       echo -e "\033[32mAttempting to restore 'File.war' file from '$BACKUPDIR/latest/'...\033[0m"
       cp -v $1/latest/File.war $WEBAPPSDIR/
       cpexitcode=$?
       if [ $cpexitcode -ne 0 ]; then
               echo -e "\033[31mError on file copy! Check if '$BACKUPDIR/latest' contents exists on '$WEBAPPS' folder.\033[0m"
               return 2
       fi
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
               makeBackup $WEBAPPSDIR/File.war
               removeFiles $WEBAPPSDIR
               echo
               getFileViaSCP $REMOTEADDR $REMOTEFILE $WEBAPPSDIR
               echo
               startTomcat
               echo
               echo -e "\033[35mDeploy process finished on `hostname`. Thank you for your attention.\033[0m"
               exit;;
       [Rr][Oo][Ll][Ll][Bb][Aa][Cc][Kk] )
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
               restoreBackup $BACKUPDIR
               echo
               startTomcat
               echo
               echo -e "\033[35mRollback to latest version process finished on `hostname`. Thank you for your attention.\033[0m"
               exit;;
       * )
               printUsage
               exit 1;;
esac