#!/bin/sh
#author: Rafael Lopes
#created at: 20120105
#about: this script checks if the filenames on a folder corresponds to it's md5

if [ -z $1 ]; then
	echo "You should give-me a directory as parameter. Exiting now..."
	exit
else
	cd $1
	for i in `ls |grep -v *.sh`
	do
		hash=`md5sum $i |cut -d ' ' -f 1`
		if [ "$i" == "$hash" ]; then
			echo "$i - $hash\t[32m[OK][0m"
		else
			echo "$i - $hash\t[31m[FAIL][0m"
		fi
	done
fi
