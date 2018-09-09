#!/bin/bash
# Example usage: ./full-pingpong.sh | grep -e ' 512 ' -e NODES -e usec
#HOSTFILE=~/bin/hosts
HOSTFILE=/mnt/resource/scratch/hosts
IMPIDIR=/opt/intel/impi/5.1.3.223/bin64
#IMPIDIR=/mnt/resource/scratch/applications/12.06.010-R8/STAR-CCM+12.06.010-R8/mpi/intel/2017.2.174/linux-x86_64/rto/intel64/bin

echo "HOSTFILE: ${HOSTFILE}"
echo "IMPIDIR:  ${IMPIDIR}"

for NODE in `cat ${HOSTFILE}`; \
    do for NODE2 in `cat ${HOSTFILE}`; \
        do echo '##################################################' && \
            echo NODES: $NODE, $NODE2 && \
            echo '##################################################' && \
            ${IMPIDIR}/mpirun\
            -hosts $NODE,$NODE2 -ppn 1 -n 2 \
            -env I_MPI_FABRICS=dapl \
            -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 \
            -env I_MPI_DYNAMIC_CONNECTION=0 \
            ${IMPIDIR}/IMB-MPI1 pingpong | grep -e ' 512 ' -e NODES -e usec; \
        done; \
    done
