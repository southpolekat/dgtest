#!/bin/bash

source ../dgtest_env.sh

MYSQL_DATABASE=my_dgtest
MYSQL_HOST=mysql1
MYSQL_USER=my_user
MYSQL_PASSWORD=changeme2
MYSQL_TABLE=my_test_table

mysql_cmd="mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE}"

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
name = "local_${format}"
argv = ["xdr_fs/xdr_fs", "$(echo ${format} | tr '[A-Z]' '[a-z]')", "${xdrive_data}"]
EOF

cat ${xdrive_conf}
