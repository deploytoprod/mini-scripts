#!/bin/sh -
#About: this script copies my FCP folders to the external HDD.
set -o pipefail

SRC="/Users/rafael/Movies"
DST="/Volumes/Box"

function copyFiles(){
    rsync -av $SRC/Final\ Cut\ Events/ $DST/Final\ Cut\ Events/
    testError $? "Events"
    rsync -av $SRC/Final\ Cut\ Projects/ $DST/Final\ Cut\ Projects/
    testError $? "Projects"
}
function showNotification(){
    ./terminal-notifier -title "$1" -message "$2"
}
function testError(){
    if test $1 != 0; then
        showNotification "fcp_bkp - Error" "Something went wrong ($2), please run the script again."
        exit 2
    fi
}
function checkRunning(){
    if pgrep $* > /dev/null
    then
        showNotification "fcp_bkp - Error" "$* is running, please exit."
        exit 1
    fi
}
function main(){
    checkRunning "Final Cut"
    copyFiles
    showNotification "fcp_bkp - Success" "Sync success, please check on Finder."
}

main