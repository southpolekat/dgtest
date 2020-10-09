#!/bin/bash

source ../dgtest_env.sh

format=${1:-csv} 	# csv, spq

if [ ${format} == "csv" ]; then
	ddl_format="CSV"
else
	ddl_format="SPQ"
fi

mkdir -p ${xdrive_path}

dglog Create xdrive config file
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = 7171 
host = ["$sdw1", "$sdw2"]

[[xdrive.mount]]
name = "s3_${format}"
argv = ["xdr_s3/xdr_s3", 
	"$(echo ${format} | tr '[A-Z]' '[a-z]')", 
	"${aws_s3_bucket_name}",
	"${aws_s3_bucket_region}",
	"/tmp/",
	"/${aws_s3_bucket_path}"]
env = [
	"AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}",
	"AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"]
EOF

cat ${xdrive_conf}

dglog xdrive stop, deplay and start
xdrctl stop ${xdrive_conf} 
xdrctl deploy ${xdrive_conf} 
xdrctl start ${xdrive_conf} 
dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop external table if exists ${db_ext_table}; 
drop external table if exists ${db_ext_table2}; 

CREATE WRITABLE EXTERNAL TABLE ${db_ext_table} (i int)
LOCATION ('xdrive://127.0.0.1:7171/s3_${format}/xdrive_#SEGID#.${format}') 
FORMAT '${ddl_format}';
\d+ ${db_ext_table}

insert into ${db_ext_table} select i::int from generate_series(1,10) i;

CREATE EXTERNAL TABLE ${db_ext_table2} (i int)
LOCATION ('xdrive://127.0.0.1:7171/s3_${format}/xdrive_#SEGID#.${format}*') 
FORMAT '${ddl_format}';
\d+ ${db_ext_table2}

SELECT gp_segment_id, * FROM ${db_ext_table2} order by i;

drop external table ${db_ext_table};
drop external table ${db_ext_table2};
EOF

dglog clean up
xdrctl stop ${xdrive_conf}
sleep 5
rm -rf ${xdrive_path} ${xdrive_conf}
gpssh -f ${hostfile} "rm -rf ${xdrive_path} ${xdrive_conf}"
