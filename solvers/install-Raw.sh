#!/bin/bash
USER=$1
#LICIP=$2
HOST=`hostname`
#echo $USER,$LICIP,$HOST

sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
