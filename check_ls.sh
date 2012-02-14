#!/bin/sh
# ABOUT: this script monitors if the fusedir is operating smoothly. there should be a line on your cronjob pointing to it
# AUTHOR: Rafael Lopes
# CREATED AT: 20120213
# CURRENT VERSION: 1.0

# CHANGELOG
# 1.0 - initial release


#DO NOT TOUCH THIS LINE BELOW
ls /fusedir/tmp &>/dev/null
lserrorcode=$?
if [ $lserrorcode -ne 0 ]; then
       NOW=`date +"%Y%m%d%H%M%S"`
       mkdir -p /tmp/Rebooted_At/
       touch /tmp/Rebooted_At/$NOW
       sleep 20
       reboot
fi