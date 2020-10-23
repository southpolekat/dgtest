#!/bin/bash

source ../dgtest_env.sh

format=${1:-csv} 	# csv, parquet, spq, orc, par

[ ${format} == "par" ] && [ ${ver} -eq 18 ] && [ ${ver_minor} -lt 34 ] && exit
[ ${format} == "par" ] && [ ${ver} -eq 16 ] && exit
[ ${format} == "parquet" ] && [ ${ver} -eq 16 ] && exit

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

[[xdrive.mount]]
name = "local_${format}"
argv = ["xdr_fs/xdr_fs", "$(echo ${format} | tr '[A-Z]' '[a-z]')", "${xdrive_data}"]
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

dglog xdrive stop, deplay and start
xdrctl stop ${xdrive_conf} 
xdrctl deploy ${xdrive_conf} 
xdrctl start ${xdrive_conf} 

dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

dglog prepare directories
gpssh -f ${hostfile} "mkdir -p ${xdrive_path}"
gpssh -f ${hostfile} "mkdir -p ${xdrive_data}"

max=1000000

psql -e -d ${db_name} << EOF
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


CREATE EXTERNAL TABLE ${db_ext_table2} (lIKE tmp)
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
gpssh -f ${hostfile} "rm -rf ${xdrive_path} ${xdrive_data} ${xdrive_conf}"
