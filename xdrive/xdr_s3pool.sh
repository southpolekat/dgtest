#!/bin/bash

source ../dgtest_env.sh

format=${1:-csv} 	# csv, par, spq, orc

[ ${format} == "par" ] && [ ${ver} -eq 18 ] && [ ${ver_minor} -lt 34 ] && exit
[ ${ver} -eq 16 ] && exit

if [ ${format} == "csv" ]; then
	ddl_format="CSV"
else
	ddl_format="SPQ"
fi

dglog Create xdrive config file
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = ${xdrive_port} 
host = ["$sdw1", "$sdw2"]

[[xdrive.xhost]]
name = "s3pool"
bin = "s3pool"
argv = ["-p", "${s3pool_port}", "-D", "${s3pool_path}"]
pidfile = "${s3pool_path}/s3pool.${s3pool_port}.pid"

[[xdrive.mount]]
name = "${aws_s3_bucket_name}"
argv = ["xdr_s3pool/xdr_s3pool", "${format}", "${s3pool_port}"]
EOF

if [ ${format} == "parquet" ] 
then
cat <<EOF >> ${xdrive_conf}
[[xdrive.xhost]]
name = "arrow"
bin = "xhost_arrow"
EOF
fi

cat ${xdrive_conf}

dglog prepare directories
gpssh -f ${hostfile} "mkdir -p ${s3pool_path}"
gpssh -f ${hostfile} "mkdir -p ${xdrive_path}"

dglog xdrive stop, deplay and start
xdrctl stop ${xdrive_conf}
xdrctl deploy ${xdrive_conf}
xdrctl start ${xdrive_conf}

dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

dglog pid of s3pool 
gpssh -f ${hostfile} pidof s3pool 

dglog clear old files in s3 

max=1000000
psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop external table if exists ${db_ext_table}; 
drop external table if exists ${db_ext_table2}; 

CREATE TEMP TABLE tmp (
	i int,
	a text,
	t timestamp
) distributed randomly;

CREATE WRITABLE EXTERNAL TABLE ${db_ext_table} (LIKE tmp) 
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/${aws_s3_bucket_name}/${aws_s3_bucket_path}/xdrive_#SEGID#.${format}') 
FORMAT '${ddl_format}';
\d+ ${db_ext_table}

CREATE EXTERNAL TABLE ${db_ext_table2} (LIKE tmp)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/${aws_s3_bucket_name}/${aws_s3_bucket_path}/xdrive_#SEGID#.${format}*') 
FORMAT '${ddl_format}';
\d+ ${db_ext_table2}

\timing
insert into ${db_ext_table} select i::int, i::text, now() from generate_series(1,$max) i;

SELECT * FROM ${db_ext_table2} order by i limit 5;
SELECT count(i) FROM ${db_ext_table2} ;
SELECT sum(i) FROM ${db_ext_table2} ;

drop external table ${db_ext_table};
drop external table ${db_ext_table2};
EOF

dglog clean up
xdrctl stop ${xdrive_conf}
PYTHONPATH= aws s3 rm --recursive s3://${aws_s3_bucket_name}/${aws_s3_bucket_path}
#rm -rf ${xdrive_path} ${s3pool_path} ${xdrive_conf}
#gpssh -f ${hostfile} "rm -rf ${xdrive_path} ${s3pool_path} ${xdrive_conf}"
