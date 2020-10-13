#!/bin/bash

source ../dgtest_env.sh

ORACLE_HOST=oracle1
ORACLE_PORT=1521
ORACLE_SERVICE=ORCLCDB.localdomain
ORACLE_USER=test_user
ORACLE_PASSWORD=test_passwd
ORACLE_TABLE=test_table
ORACLE_JAR=/home/gpadmin/ojdbc8.jar	# download from Oracle		 

oracle_cmd="oracle --host=${ORACLE_HOST} --port=${ORACLE_PORT} --user=${ORACLE_USER} --password=${ORACLE_PASSWORD} ${ORACLE_DATABASE}"

mkdir -p ${xdrive_path}
mkdir -p ${xdrive_data}

dglog Create xdrive config file
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = ${xdrive_port}
host = ["$sdw1", "$sdw2"]

[[xdrive.mount]]
name = "oracle_mnt"
argv = ["/usr/bin/java",
        "-classpath",
	"jars/ojdbc8.jar:jars/vitessedata-db-plugin.jar",
        "com.vitessedata.xdrive.jdbc.Main"]
env = ["CONNECTION_STRING=jdbc:oracle:thin:${ORACLE_USER}/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE}"]
EOF
cat ${xdrive_conf}

dglog xdrive stop, deplay and start
xdrctl stop ${xdrive_conf} 
xdrctl deploy ${xdrive_conf} 
xdrctl start ${xdrive_conf} 
dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

dglog create a soft link to oracle jdbc jar 
gpssh -f ${hostfile} ln -s ${ORACLE_JAR} ${xdrive_path}/plugin/jars/ojdbc8.jar

psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop external table if exists ${db_ext_table}; 
drop external table if exists ${db_ext_table2}; 

CREATE WRITABLE EXTERNAL TABLE ${db_ext_table} (i int)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/oracle_mnt/${ORACLE_TABLE}') 
FORMAT 'SPQ';
\d+ ${db_ext_table}


CREATE EXTERNAL TABLE ${db_ext_table2} (i int)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/oracle_mnt/${ORACLE_TABLE}') 
FORMAT 'SPQ';
\d+ ${db_ext_table2}

insert into ${db_ext_table} select i::int from generate_series(1,5) i;
SELECT * FROM ${db_ext_table2};

drop external table ${db_ext_table};
drop external table ${db_ext_table2};
EOF

