#!/bin/sh
# ABOUT: this script monitors if the fusedir is operating smoothly. there should be a line on your cronjob pointing to it
# AUTHOR: Rafael Lopes
# CREATED AT: 201202132100
# LAST MODIFIED: 201202142030
# CURRENT VERSION: 1.2

# CHANGELOG
# 1.2 - now the script sends an email before rebooting the machine
# 1.1 - introduces 'status' input, printing nothing when not inputed anything (to keep cron clean)
# 1.0 - initial release


#DO NOT TOUCH THIS LINE BELOW
ls /fusedir/tmp &>/dev/null
lserrorcode=$?
if [ $lserrorcode -ne 0 ]; then
        if [ "$1" == "status" ]; then
                echo -e "\033[31mServer `hostname` has problems on '/fusedir' mount. Server will be rebooted automatically soon.\033[0m"
                exit 1;
        fi
        NOW=`date +"%Y%m%d%H%M%S"`
        mkdir -p /tmp/Rebooted_At/
        touch /tmp/Rebooted_At/$NOW
        echo -en "Server `hostname` rebooted because '/fusedir' was with problems. This incident is logged on '/tmp/Rebooted_At' folder on `hostname` server.\n\nThis e-mail was automatically sent by the script '/opt/rsync/fuse_check.sh', please do not reply. Thank you." |mail -s "`hostname` rebooted at `date`" -r infra@grupoxango.com infra@grupoxango.com
        wall "*** ATTENTION: /fusedir IS NOT WORKING PROPERLY! THE SERVER WILL REBOOT IN 15 SECONDS ***"
        sleep 20
        reboot
else
        if [ "$1" == "status" ]; then
                echo -e "\033[32mServer `hostname` runs '/fusedir' smoothly.\033[0m"
                exit;
        fi
fi
