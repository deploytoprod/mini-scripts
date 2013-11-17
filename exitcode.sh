#!/bin/sh

function status
{
       echo saindo com 43
       return 43
}

status
exitcode=$?
if [ $exitcode -eq 0 ]; then
       echo saiu direitim
else
       echo saiu com $exitcode
fi