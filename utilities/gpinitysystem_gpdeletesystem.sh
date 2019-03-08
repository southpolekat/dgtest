#!/bin/bash

master_dir=/data/master
data_dir=/data/primary
master_port=6432

cat > hostfile << END
sdw1
sdw2
END

cat > cluster.conf << END
ARRAY_NAME=DG
MACHINE_LIST_FILE=hostfile
SEG_PREFIX=gpseg
PORT_BASE=40000
declare -a DATA_DIRECTORY=( $data_dir $data_dir )
MASTER_HOSTNAME=mdw
MASTER_DIRECTORY=$master_dir
MASTER_PORT=$master_port
TRUSTED_SHELL=/usr/bin/ssh
CHECK_POINT_SEGMENTS=8
ENCODING=UNICODE
MASTER_MAX_CONNECT=25
END

mkdir -p $master_dir
gpssh -f hostfile mkdir -p $data_dir

gpinitsystem -a -c cluster.conf -h hostfile
### -a : no prompt
### -c <config_file>
### -h <host_file>

gpstate

gpdeletesystem -f -d $master_dir/gpseg-1
### -f : force
### -d <master_data_directory>
