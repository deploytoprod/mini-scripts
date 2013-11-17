#!/bin/sh -e
#About: this script copies my FCP folders to the external HDD.
set -o pipefail

SRC="/Users/rafael/Movies"
DST="/Volumes/Box"

function copyFiles(){
    rsync -av $SRC/Final\ Cut\ Events/* $DST/Final\ Cut\ Events/
    rsync -av $SRC/Final\ Cut\ Projects/* $DST/Final\ Cut\ Projects/
}
function showNotification(){
    ./terminal-notifier -title "$1" -message "$2"
}
function checkRunning(){
    if [ `pgrep $*` != 1 ];then
        showNotification "fcp_bkp - Error" "FCP is running, please exit."
        return 1;
    fi
}
function main(){
    checkRunning "Final Cut"
    copyFiles
}

main