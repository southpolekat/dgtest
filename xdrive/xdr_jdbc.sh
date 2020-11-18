#!/bin/bash

source ../dgtest_env.sh

src=${1:-mysql} 	# mysql, oracle, db2, postgres 
max=${2:-10}      # number of records to insert and select

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
   db2)
      JAR_NAME=db2jcc-db2jcc4.jar
      JAR_PATH=${DB2_JAR}
      CON_STR="jdbc:db2://${DB2_HOST}:${DB2_PORT}/${DB2_DATABASE}:user=${DB2_USER};password=${DB2_PASSWORD};"
      TABLE=${DB2_TABLE}
      ;;
   postgres)
      JAR_NAME=postgresql-42.2.1.jar
      JAR_PATH=${POSTGRES_JAR}
      CON_STR="jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}?user=${POSTGRES_USER}&password=${POSTGRES_PASSWORD}&stringtype=unspecified"
      TABLE=${POSTGRES_TABLE}
      ;;
esac

dglog Create xdrive config file
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = ${xdrive_port}
host = ${xdrive_host} 

[[xdrive.mount]]
name = "${xdrive_mount}"
argv = ["/usr/bin/java",
        "-Xmx1G",
        "-classpath",
	"jars/${JAR_NAME}:jars/vitessedata-db-plugin.jar",
        "com.vitessedata.xdrive.jdbc.Main"]
env = ["CONNECTION_STRING=${CON_STR}"]
EOF
cat ${xdrive_conf}

dglog prepare directory
gpssh -f ${hostfile} mkdir -p ${xdrive_path}

dglog xdrive stop, deploy and start
xdrctl stop ${xdrive_conf} 
xdrctl deploy ${xdrive_conf} 
xdrctl start ${xdrive_conf} 

dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

dglog copy ${JAR_PATH} 
gpssh -f ${hostfile} cp ${JAR_PATH} ${xdrive_path}/plugin/jars/

psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop external table if exists ${db_ext_table}; 
drop external table if exists ${db_ext_table2}; 

CREATE TEMP table tmp (
   i int,
   a text,
   d double precision,
   t timestamp
) distributed randomly;

CREATE WRITABLE EXTERNAL TABLE ${db_ext_table} (LIKE tmp)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/${xdrive_mount}/${TABLE}') 
FORMAT 'SPQ';
\d+ ${db_ext_table}

CREATE EXTERNAL TABLE ${db_ext_table2} (LIKE tmp)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/${xdrive_mount}/${TABLE}') 
FORMAT 'SPQ';
\d+ ${db_ext_table2}

\timing
insert into ${db_ext_table} select 
   i::int,
   md5(random()::text),
   random(),
   now()
from generate_series(1,$max) i;

SELECT * FROM ${db_ext_table2} order by i limit 5;
SELECT * FROM ${db_ext_table2} where i = 1;
SELECT count(i) FROM ${db_ext_table2} ;
SELECT sum(i), sum(d) FROM ${db_ext_table2} ;

CREATE TEMP TABLE tmp2 AS SELECT * FROM ${db_ext_table2} distributed randomly;

--drop external table ${db_ext_table};
--drop external table ${db_ext_table2};
EOF
