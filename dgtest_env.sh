#!/bin/bash

set -e

num_host=$(psql postgres -t -c "select count(distinct hostname) from gp_segment_configuration;")

# hostname of segment 1 and segment 2
sdw1=sdw1
sdw2=sdw2

db_host=localhost
db_port=5432
db_name=dgtest
db_user=$(whoami)
db_schema=public
db_table=dgtest_tt
db_table2=dgtest_tt2
db_ext_table=dgtest_ext
db_ext_table2=dgtest_ext2

loftd_host=mdw
loftd_path=/tmp/loftdata
loftd_port=8787

loftd_host2=mdw
loftd_path2=/tmp/loftdata2
loftd_port2=8788

xdrive_port=7171
xdrive_path=/tmp/xdrive
xdrive_conf=/tmp/xdrive.toml
xdrive_data=/tmp/data
xdrive_mount=mnt
if [ ${num_host} -eq 1 ]; then
   xdrive_host="[\"localhost\"]"
else
   xdrive_host="[\"$sdw1\", \"$sdw2\"]"
fi

s3pool_port=12345
s3pool_path=/tmp/s3pool

hostfile=~/hostfile

# EXPORT AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
aws_s3_bucket_name=vd-s3-tmp
aws_s3_bucket_path=dgtest
aws_s3_bucket_region=us-east-1

s3pool_port=12345
s3pool_path=/tmp/s3pool

MYSQL_HOST=mysql1
MYSQL_PORT=3306
MYSQL_DATABASE=test_db
MYSQL_USER=test_user
MYSQL_PASSWORD=test_passwd
MYSQL_TABLE=test_table
MYSQL_JAR=/usr/share/java/mysql.jar     # install on Ubuntu 16.04 : sudo apt install libmysql-java

ORACLE_HOST=oracle1
ORACLE_PORT=1521
ORACLE_SERVICE=ORCLCDB.localdomain
ORACLE_USER=test_user
ORACLE_PASSWORD=test_passwd
ORACLE_TABLE=test_table
ORACLE_JAR=~/ojdbc8.jar     # download from Oracle  

DB2_HOST=my_db2
DB2_PORT=50000
DB2_USER=db2inst1
DB2_DATABASE=test_db
DB2_PASSWORD=test_passwd
DB2_TABLE=test_table
DB2_JAR=~/db2jcc-db2jcc4.jar # download from https://repo1.maven.org/maven2/com/ibm/db2/jcc/db2jcc/db2jcc4/db2jcc-db2jcc4.jar

POSTGRES_HOST=my_pg9
POSTGRES_PORT=5432
POSTGRES_USER=test_user
POSTGRES_PASSWORD=test_passwd
POSTGRES_DATABASE=test_db
POSTGRES_TABLE=test_table
POSTGRES_JAR=~/postgresql-42.2.1.jar

ver=$(psql postgres -t -c "show vitesse.version" | cut -f4 -d ' ' | cut -f1 -d '.')
ver_minor=$(psql postgres -t -c "show vitesse.version" | cut -f4 -d ' ' | cut -f2 -d '.')

function dglog {
	echo
	echo "##### [$(date +%T)] $@"
}
