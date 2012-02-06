#!/bin/sh
#author: Rafael Lopes
#created at: 20120105
#about: this script intends to receive a directory and rename all of it's files to match with their md5

if [ -z $1 ]; then
   echo "You should give-me a directory as parameter. Exiting now..."
   exit
else
	cd $1
	for i in `ls |grep -v *.sh`
	do
		hash=`md5sum $i |cut -d ' ' -f 1`
		mv $i $hash
		echo "[31m$i[0m -> [32m$hash[0m"
	done
fi
