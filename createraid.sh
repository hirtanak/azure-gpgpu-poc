#!/bin/bash

sudo date; cat /etc/redhat-relase;

echo "Enter number of disks. default is 8:"
read DISKS

ENDDRIVE=$((66 + ${DISKS}))
for i in `seq 67 ${ENDDRIVE}`; do
DISKDRIVE=`printf "%b\n" $(printf "%s%x" "\\x" $i)`
DISKDRIVE=`echo $DISKDRIVE | tr "C-Z" "c-z"`
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- mklabel gpt   # GPT(GUID Partition Table)
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- mkpart primary ext4 1 -1
sudo parted -s -a optimal /dev/sd${DISKDRIVE} -- set 1 raid on
done

yes | sudo mdadm --create /dev/md0 --level=0 --raid-devices=${DISKS} /dev/sd[c-${DISKDRIVE}]1
sudo mkfs -t ext4 /dev/md0
sudo mkdir -p /mnt/resource/md0
sudo mount /dev/md0 /mnt/resource/md0
echo "sudo chown user:user /mnt/resource/md0" 
