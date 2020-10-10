#!/bin/bash

source ../dgtest_env.sh

MYSQL_HOST=mysql1
MYSQL_PORT=3306
MYSQL_DATABASE=my_dgtest
MYSQL_USER=my_user
MYSQL_PASSWORD=changeme2
MYSQL_TABLE=my_test_table
MYSQL_JAR=/usr/share/java/mysql.jar

mysql_cmd="mysql --host=${MYSQL_HOST} --port=${MYSQL_PORT} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE}"

dglog Create a testing table ${MYSQL_TABLE} in mysql
q="
DROP TABLE IF EXISTS ${MYSQL_TABLE};
CREATE TABLE ${MYSQL_TABLE} ( i int ); 
SHOW TABLES;
"
echo ${q} | ${mysql_cmd} 

mkdir -p ${xdrive_path}
mkdir -p ${xdrive_data}

dglog Create xdrive config file
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = ${xdrive_port}
host = ["$sdw1", "$sdw2"]

[[xdrive.mount]]
name = "mysql_mnt"
argv = ["/usr/bin/java",
        "-classpath",
	"jars/mysql.jar:jars/vitessedata-db-plugin.jar",
        "com.vitessedata.xdrive.jdbc.Main"]
env = ["CONNECTION_STRING=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}?user=${MYSQL_USER}&password=${MYSQL_PASSWORD}"]
EOF
cat ${xdrive_conf}

dglog xdrive stop, deplay and start
xdrctl stop ${xdrive_conf} 
xdrctl deploy ${xdrive_conf} 
xdrctl start ${xdrive_conf} 
dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

dglog create a soft link to mysql.jar 
gpssh -f ${hostfile} ln -s ${MYSQL_JAR} ${xdrive_path}/plugin/jars/mysql.jar

psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop external table if exists ${db_ext_table}; 
drop external table if exists ${db_ext_table2}; 

CREATE WRITABLE EXTERNAL TABLE ${db_ext_table} (i int)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/mysql_mnt/${MYSQL_TABLE}') 
FORMAT 'SPQ';
\d+ ${db_ext_table}


CREATE EXTERNAL TABLE ${db_ext_table2} (i int)
LOCATION ('xdrive://127.0.0.1:${xdrive_port}/mysql_mnt/${MYSQL_TABLE}') 
FORMAT 'SPQ';
\d+ ${db_ext_table2}

insert into ${db_ext_table} select i::int from generate_series(1,10) i;
SELECT gp_segment_id, * FROM ${db_ext_table2} order by i;

drop external table ${db_ext_table};
drop external table ${db_ext_table2};
EOF

