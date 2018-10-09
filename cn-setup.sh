#!/bin/bash
echo ##################################################
echo ############# Compute Node Setup #################
echo ##################################################
IPPRE=$1
USER=$2
GANG_HOST=$3
HOST=`hostname`
if grep -q $IPPRE /etc/fstab; then FLAG=MOUNTED; else FLAG=NOTMOUNTED; fi


if [ $FLAG = NOTMOUNTED ] ; then
    echo $FLAG
    echo installing NFS and mounting
    pkill -9 yum
    sleep 10
    yum install -y -q nfs-utils pdsh
    mkdir -p /data/scratch
    chmod 777 /data/scratch
    chown -R $USER:$USER /data/$USER/
    systemctl enable rpcbind
    systemctl enable nfs-server
    systemctl enable nfs-lock
    systemctl enable nfs-idmap
    systemctl start rpcbind
    systemctl start nfs-server
    systemctl start nfs-lock
    systemctl start nfs-idmap
    localip=`hostname -i | cut --delimiter='.' -f -3`
    echo "$IPPRE:/data/scratch    /data/scratch   nfs   defaults 0 0" | tee -a /etc/fstab
    mount -a
    df | grep $IPPRE
    impi_version=`ls /opt/intel/impi`
    source /opt/intel/impi/${impi_version}/bin64/mpivars.sh
    ln -s /opt/intel/impi/${impi_version}/intel64/bin/ /opt/intel/impi/${impi_version}/bin
    ln -s /opt/intel/impi/${impi_version}/lib64/ /opt/intel/impi/${impi_version}/lib
        
    # fix mount problem
    echo "@reboot ~/bootcron.sh" | tee -a /var/spool/cron/root
    echo "*/15 * * * * ~/bootcron.sh" | tee -a /var/spool/cron/root
    
    # create script
    echo "#!/bin/bash" | tee -a ~/bootcron.sh
    echo "if [ -d /data/scratch ]; then" | tee -a ~/bootcron.sh
    echo "echo '[bootcron] Already mounted'" | tee -a ~/bootcron.sh
    echo "else" | tee -a ~/bootcron.sh
    echo "mkdir -p /data/scratch" | tee -a ~/bootcron.sh
    echo "chown ${USER}:${USER} /data/scratch" | tee -a ~/bootcron.sh
    echo "mount -t nfs $IPPRE:/data/scratch /data/scratch" | tee -a ~/bootcron.sh
    echo "fi" | tee -a ~/bootcron.sh
    chmod +x ~/bootcron.sh
    ln -s /root/bootcron.sh /home/${USER}/bootcron.sh
    
    echo export I_MPI_FABRICS=shm:dapl >> /home/$USER/.bashrc
    echo export I_MPI_DAPL_PROVIDER=ofa-v2-ib0 >> /home/$USER/.bashrc
    echo export I_MPI_ROOT=/opt/intel/impi/${impi_version} >> /home/$USER/.bashrc
    echo export PATH=/opt/intel/impi/${impi_version}/bin64:$PATH >> /home/$USER/.bashrc
    echo export I_MPI_DYNAMIC_CONNECTION=0 >> /home/$USER/.bashrc
        
else
    echo already mounted
    df | grep $IPPRE
fi
