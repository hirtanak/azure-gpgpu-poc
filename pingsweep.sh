#!/bin/bash

echo "Example: 10.0.0. for 10.0.0.0/24"
echo "Enter Your Sweep Subnet: "
read SUBNET

for i in `seq 4 254`; do ping -c 1 ${SUBNET}$i | tr \\n ' ' | awk '/1 received/ {print $2}'; done
