#!/bin/bash

source ../dgtest_env.sh

src=${1:-mysql} 	# mysql, oracle 

case ${src} in 
	mysql)
      JAR_NAME=mysql.jar
		JAR_PATH=${MYSQL_JAR}
      CON_STR="jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}?user=${MYSQL_USER}&password=${MYSQL_PASSWORD}"		
      TABLE=${MYSQL_TABLE}
		;;
	oracle)
      JAR_NAME=ojdbc8.jar
		JAR_PATH=${ORACLE_JAR}
      CON_STR="jdbc:oracle:thin:${ORACLE_USER}/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE}"
      TABLE=${ORACLE_TABLE}
		;;
esac

dglog Create xdrive config file
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = ${xdrive_port}
host = ["$sdw1", "$sdw2"]

[[xdrive.mount]]
name = "${xdrive_mount}"
argv = ["/usr/bin/java",
        "-classpath",
	"jars/${JAR_NAME}:jars/vitessedata-db-plugin.jar",
        "com.vitessedata.xdrive.jdbc.Main"]
env = ["CONNECTION_STRING=${CON_STR}"]
EOF
cat ${xdrive_conf}

dglog prepare directory
gpssh -f ${hostfile} mkdir -p ${xdrive_path}

dglog xdrive stop, deplay and start
xdrctl stop ${xdrive_conf} 
xdrctl deploy ${xdrive_conf} 
xdrctl start ${xdrive_conf} 

dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

dglog create a soft link to ${JAR_PATH} 
gpssh -f ${hostfile} ln -s ${JAR_PATH} ${xdrive_path}/plugin/jars/

psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop external table if exists ${db_ext_table}; 
drop external table if exists ${db_ext_table2}; 

CREATE WRITABLE EXTERNAL TABLE ${db_ext_table} (i int)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/${xdrive_mount}/${TABLE}') 
FORMAT 'SPQ';
\d+ ${db_ext_table}

CREATE EXTERNAL TABLE ${db_ext_table2} (i int)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/${xdrive_mount}/${TABLE}') 
FORMAT 'SPQ';
\d+ ${db_ext_table2}

\timing
insert into ${db_ext_table} select i::int from generate_series(1,5) i;
SELECT * FROM ${db_ext_table2} order by i limit 5;
SELECT * FROM ${db_ext_table2} where i = 3;
SELECT sum(i) FROM ${db_ext_table2} ;
SELECT count(i) FROM ${db_ext_table2} ;

drop external table ${db_ext_table};
drop external table ${db_ext_table2};
EOF
