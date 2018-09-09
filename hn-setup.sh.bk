#!/bin/bash
set -x

SOLVER=$1
USER=$2
PASS=$3
DOWN=$4
LICIP=$5


IP=`ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
localip=`echo $IP | cut --delimiter='.' -f -3`
myhost=`hostname`

echo User is: $USER
echo Pass is: $PASS
echo License IP is: $LICIP
echo Model is: $DOWN

cat << EOF >> /etc/security/limits.conf
*               hard    memlock         unlimited
*               soft    memlock         unlimited
EOF

#Create directories needed for configuration
SHARE_HOME=/mnt/resource/scratch
mkdir -p /home/$USER/.ssh
mkdir -p /home/$USER/bin
mkdir -p /mnt/resource/scratch/applications
mkdir -p /mnt/resource/scratch/INSTALLERS
mkdir -p /mnt/resource/scratch/benchmark
mkdir -p /mnt/lts

ln -s /mnt/resource/scratch/ /home/$USER/scratch
ln -s /mnt/lts /home/$USER/lts

#Following lines are only needed if the head node is an RDMA connected VM
#impi_version=`ls /opt/intel/impi`
#source /opt/intel/impi/${impi_version}/bin64/mpivars.sh
#ln -s /opt/intel/impi/${impi_version}/intel64/bin/ /opt/intel/impi/${impi_version}/bin
#ln -s /opt/intel/impi/${impi_version}/lib64/ /opt/intel/impi/${impi_version}/lib

#Install needed packages
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
rpm --import /etc/pki/rpm-gpg/OpenLogic-GPG-KEY
yum check-update
yum install -y epel-release
yum install -y nfs-utils sshpass nmap htop pdsh screen git psmisc
yum install -y gcc* libffi-devel python-devel openssl-devel --disableexcludes=all
#yum groupinstall -y "X Window System"
yum install -y parted fio

#install az cli
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
yum install -y azure-cli

#Use ganglia install script to install ganglia, this is downloaded via the ARM template
#chmod +x install_ganglia.sh
#./install_ganglia.sh $myhost azure 8649

#Setup the NFS server
echo "/mnt/resource/scratch $localip.*(rw,sync,no_root_squash,no_all_squash)" | tee -a /etc/exports
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
systemctl restart nfs-server

mv clusRun.sh cn-setup.sh install-$SOLVER.sh /home/$USER/bin
chmod +x /home/$USER/bin/*.sh
chown $USER:$USER /home/$USER/bin
nmap -sn $localip.* | grep $localip. | awk '{print $5}' > /home/$USER/bin/hostips

sed -i '/\<'$IP'\>/d' /home/$USER/bin/hostips
sed -i '/\<10.0.0.1\>/d' /home/$USER/bin/hostips

echo -e  'y\n' | ssh-keygen -f /home/$USER/.ssh/id_rsa -t rsa -N ''
echo 'Host *' >> /home/$USER/.ssh/config
echo 'StrictHostKeyChecking no' >> /home/$USER/.ssh/config
chmod 400 /home/$USER/.ssh/config
chown $USER:$USER /home/$USER/.ssh/config

mkdir -p ~/.ssh
echo 'Host *' >> ~/.ssh/config
echo 'StrictHostKeyChecking no' >> ~/.ssh/config
chmod 400 ~/.ssh/config

for NAME in `cat /home/$USER/bin/hostips`; do sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'hostname' >> /home/$USER/bin/hosts;done
NAMES=`cat /home/$USER/bin/hostips` #names from names.txt file

for name in `cat /home/$USER/bin/hostips`; do
        sshpass -p "$PASS" ssh $USER@$name "mkdir -p .ssh"
        cat /home/$USER/.ssh/config | sshpass -p "$PASS" ssh $USER@$name "cat >> .ssh/config"
        cat /home/$USER/.ssh/id_rsa | sshpass -p "$PASS" ssh $USER@$name "cat >> .ssh/id_rsa"
        cat /home/$USER/.ssh/id_rsa.pub | sshpass -p "$PASS" ssh $USER@$name "cat >> .ssh/authorized_keys"
        sshpass -p "$PASS" ssh $USER@$name "chmod 700 .ssh; chmod 640 .ssh/authorized_keys; chmod 400 .ssh/config; chmod 400 .ssh/id_rsa"
        cat /home/$USER/bin/hostips | sshpass -p "$PASS" ssh $USER@$name "cat >> /home/$USER/hostips"
        cat /home/$USER/bin/hosts | sshpass -p "$PASS" ssh $USER@$name "cat >> /home/$USER/hosts"
        cat /home/$USER/bin/cn-setup.sh | sshpass -p "$PASS" ssh $USER@$name "cat >> /home/$USER/cn-setup.sh"
        sshpass -p $PASS ssh -t -t -o ConnectTimeout=2 $USER@$name 'echo "'$PASS'" | sudo -S sh /home/'$USER'/cn-setup.sh '$IP $USER $myhost &
done

# downlaod scripts
cd /home/$USER/bin
wget https://raw.githubusercontent.com/hirtanak/AHOD-HPC/master/full-pingpong.sh
chmod +x ./full-pingpong.sh
wget https://raw.githubusercontent.com/hirtanak/AHOD-HPC/master/pingsweep.sh
chmod +x ./pingsweep.sh
wget https://raw.githubusercontent.com/hirtanak/AHOD-HPC/master/reauth_rescale.sh
chmod +x ./reauth_rescale.sh
wget https://raw.githubusercontent.com/hirtanak/AHOD-HPC/master/createraid.sh
chmod +x ./createraid.sh

cp /home/$USER/bin/hosts /mnt/resource/scratch/hosts
chown -R $USER:$USER /home/$USER/.ssh/
chown -R $USER:$USER /home/$USER/bin/
chown -R $USER:$USER /mnt/lts
chown -R $USER:$USER /mnt/resource/scratch/
chmod -R 744 /mnt/resource/scratch/

# Don't require password for HPC user sudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    
# Disable tty requirement for sudo
sed -i 's/^Defaults[ ]*requiretty/# Defaults requiretty/g' /etc/sudoers

# run install the solver
#name=`head -1 /home/$USER/bin/hostips`
#cat install-$SOLVER.sh | sshpass -p "$PASS" ssh $USER@$name "cat >> /home/$USER/install-$SOLVER.sh"
#sshpass -p $PASS ssh -t -t -o ConnectTimeout=2 $USER@$name source install-$SOLVER.sh $USER $LICIP $DOWN > script_output
cd /home/$USER/bin
bash install-$SOLVER.sh $SHARE_HOME $LICIP $DOWN ${USER}

chown -R $USER:$USER /mnt/resource/scratch/
chmod -R 744 /mnt/resource/scratch/
