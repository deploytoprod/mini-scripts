#!/bin/sh
c=1
while [ $c -le 5 ]
do
       echo "$c times"
       (( c++ ))
done