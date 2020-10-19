#!/bin/sh
export flavor="Linux-64bit"
if [ $1 == "linux/amd64" ] ; then
    flavor="Linux-64bit"
elif [ $1 == "linux/arm64" ] ; then
    flavor="Linux-ARM64"
fi

echo $flavor