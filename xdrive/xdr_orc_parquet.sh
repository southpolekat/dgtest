#!/bin/bash

source ../dgtest_env.sh

format=${1:-orc} 	# orc, parquet

ddl_format="SPQ"

dglog clear xdrive and data
gpssh -f ${hostfile} "rm -rf ${xdrive_data} ${xdrive_path}"

dglog Create xdrive config file
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = ${xdrive_port} 
host = ${xdrive_host} 

[[xdrive.mount]]
name = "local_${format}"
argv = [
	"/usr/bin/java", 
	"-Xmx1G", 
	"-cp",
	"jars/vitessedata-file-plugin.jar",
	"com.vitessedata.xdrive.${format}.Main",
	"nfs",
	"${xdrive_data}"
	]
EOF

cat ${xdrive_conf}

dglog xdrive stop, deploy and start
xdrctl stop ${xdrive_conf} 
xdrctl deploy ${xdrive_conf} 
xdrctl start ${xdrive_conf} 
dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

dglog prepare directories
gpssh -f ${hostfile} "mkdir -p ${xdrive_path}"
gpssh -f ${hostfile} "mkdir -p ${xdrive_data}"

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
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/local_${format}/xdrive_#SEGID#.${format}') 
FORMAT '${ddl_format}';
\d+ ${db_ext_table}

CREATE EXTERNAL TABLE ${db_ext_table2} (LIKE tmp)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/local_${format}/xdrive_#SEGID#.${format}*') 
FORMAT '${ddl_format}';
\d+ ${db_ext_table2}

\timing
INSERT INTO  ${db_ext_table} SELECT i::int, i::text, now() from generate_series(1,$max) i;
SELECT * FROM ${db_ext_table2} order by i limit 5;
SELECT sum(i) FROM ${db_ext_table2} ;
SELECT count(i) FROM ${db_ext_table2} ;

drop external table ${db_ext_table};
drop external table ${db_ext_table2};
EOF

dglog clean up
xdrctl stop ${xdrive_conf}
#rm -rf ${xdrive_path} ${xdrive_data} ${xdrive_conf}
#gpssh -f ${hostfile} "rm -rf ${xdrive_path} ${xdrive_data} ${xdrive_conf}"
