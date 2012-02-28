#!/bin/sh
#author: Rafael Lopes
#created at: 20120105
#about: this script creates 200 different 6MB files on a specified folder

if [ -z $1 ]; then
   echo "You should give-me a directory as parameter. Exiting now..."
   exit
else
	cd $1
	i=1
	while [ $i -le 200 ];
	do
		dd if=/dev/urandom of=$i bs=1MB count=6
		echo "[32m$i criado[0m"
		i=`expr $i + 1`	
	done
fi
