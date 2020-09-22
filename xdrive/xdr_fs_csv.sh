#!/bin/bash

source ../dgtest_env.sh

mkdir -p ${xdrive_path}
mkdir -p ${xdrive_data}

### Create xdrive config file
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = 7171 
host = ["$sdw1", "$sdw2"]

[[xdrive.xhost]]
name = "arrow"
bin = "xhost_arrow"

[[xdrive.mount]]
name = "local_csv"
argv = ["xdr_fs/xdr_fs", "csv", "${xdrive_data}"]
EOF

xdrctl stop ${xdrive_conf} 
xdrctl deploy ${xdrive_conf} 
xdrctl start ${xdrive_conf} 
gpssh -f ${hostfile} pidof xdrive

gpssh -f ${hostfile} "rm -rf ${xdrive_data}"
gpssh -f ${hostfile} "mkdir -p ${xdrive_data}"

psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop external table if exists ${db_ext_table}; 
drop external table if exists ${db_ext_table2}; 

CREATE WRITABLE EXTERNAL TABLE ${db_ext_table} (i int)
LOCATION ('xdrive://127.0.0.1:7171/local_csv/xdrive_#SEGID#.csv') 
FORMAT 'CSV';

insert into ${db_ext_table} select i::int from generate_series(1,10) i;

CREATE EXTERNAL TABLE ${db_ext_table2} (i int)
LOCATION ('xdrive://127.0.0.1:7171/local_csv/xdrive_#SEGID#.csv*') 
FORMAT 'CSV';

SELECT gp_segment_id, * FROM ${db_ext_table2};
SELECT gp_segment_id, count(*) FROM ${db_ext_table2} group by (gp_segment_id);

drop external table ${db_ext_table};
drop external table ${db_ext_table2};
EOF

xdrctl stop ${xdrive_conf}
rm -rf ${xdrive_path} ${xdrive_data} ${xdrive_conf}
