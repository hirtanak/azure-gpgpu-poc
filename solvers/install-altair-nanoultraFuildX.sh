#!/bin/bash
set -x

SHARE_HOME=$1
LICIP=$2
HOST=`hostname`
DOWN=$3
USER=$4
SHARE_DATA="/home/${USER}"
echo $USER,$SHARE_HOME,$LICIP,$HOST,$DOWN,$SHARE_DATA

# install library
#yum install -y

# create directory
mkdir -p $SHARE_DATA/altair
mkdir -p $SHARE_DATA/altair/ultraFuildX

wget -q https://hirostpublicshare.blob.core.windows.net/solvers/20180806_nanoFluidX_SA_2018.0.0.10_beta_SP.tar.gz -O $SHARE_DATA/altair/20180806_nanoFluidX_SA_2018.0.0.10_beta_SP.tar.gz
wget -q https://hirostpublicshare.blob.core.windows.net/solvers/ultraFluidX.v2018.0.1.2.linux64.bin -O $SHARE_DATA/altair/ultraFuildX/ultraFluidX.v2018.0.1.2.linux64.bin
wget -q https://hirostpublicshare.blob.core.windows.net/solvers/altair_licensing_14.0.2.linux_x64.bin -O $SHARE_DATA/altair/altair_licensing_14.0.2.linux_x64.bin
wget -q https://hirostpublicshare.blob.core.windows.net/solvers/$DOWN.tar.gz -O $SHARE_DATA/altair/$DOWN.tar.gz
chown -R $USER:$USER /home/$USER/altair

cd $SHARE_DATA/altair/
tar -zxvf $SHARE_DATA/altair/20180806_nanoFluidX_SA_2018.0.0.10_beta_SP.tar.gz -C $SHARE_DATA/altair
chown -R $USER:$USER /home/$USER/altair/20180806_nanoFluidX_SA_2018.0.0.10_beta_SP

cd $SHARE_DATA/altair/ultraFuildX
chown -R $USER:$USER $SHARE_DATA/altair/ultraFuildX/ultraFluidX.v2018.0.1.2.linux64.bin
chmod +x $SHARE_DATA/altair/ultraFuildX/ultraFluidX.v2018.0.1.2.linux64.bin
sh $SHARE_DATA/altair/ultraFuildX/ultraFluidX.v2018.0.1.2.linux64.bin

chmod 755 $SHARE_DATA/altair/altair_licensing_14.0.2.linux_x64.bin

#ompi setting configuration
#nanoFuildX
echo "btl=tcp,self,sm" >> /home/$USER/altair/20180806_nanoFluidX_SA_2018.0.0.10_beta_SP/libs/openmpi/2.1.2-ibverbs/etc/openmpi-mca-params.conf
echo "btl_tcp_if_include=docker0,lo,eth0" >> /home/$USER/altair/20180806_nanoFluidX_SA_2018.0.0.10_beta_SP/libs/openmpi/2.1.2-ibverbs/etc/openmpi-mca-params.conf

#ultraFuildX
echo "btl=tcp,self,sm" >> /home/$USER/altair/ultraFuildX/mpi/linux64/openmpi/openmpi-mca-params.conf
echo "btl_tcp_if_include=docker0,lo,eth0" >> /home/$USER/altair/ultraFuildX/mpi/linux64/openmpi/openmpi-mca-params.conf

