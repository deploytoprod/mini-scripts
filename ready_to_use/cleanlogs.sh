#!/bin/bash
# author: Rafael Lopes
# created at: 201202021742
# about: a tiny script to clean customized rsync logs

read -p "Do you really want to clean rsync logs? [y/N] " yn
case $yn in
        [Yy]* )
                rm -f /opt/rsync/log/*;
                syslog_pid_file="/var/run/syslogd.pid"
                syslogd_pid=`sudo cat "$syslog_pid_file"`
                sudo kill -SIGHUP $syslogd_pid
                echo "Ok, logs cleaned, and pid $syslogd_pid killed as well.";
                exit;;
        [Nn]* )
                echo "Uhh! That was almost!";
                exit;;
        * )
                echo "Uhh! That was almost!";
                exit;;
esac
