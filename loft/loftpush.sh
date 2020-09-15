#!/bin/bash

set -e

source ../dgtest_env.sh

[ $ver -ne "16" ] && exit

mkdir -p ${loftd_path2}
echo "port=${loftd_port2}" > ${loftd_path2}/loftd.conf
loftd -D ${loftd_path2}

loftpush ${loftd_path}/base http://${loftd_host2}:${loftd_port2}


ddl=/tmp/${db_table}.xql
ext=${db_table}_ext2

cat ${loftd_path2}/base/${db_name}/${db_schema}/${db_table}/*.xsql \
	| sed -e "s/\"${db_table}\"/\"${ext}\"/" \
	| sed -e "s/__LOFTD_ADDR__/${loftd_host2}:${loftd_port2}/" \
	| sed -e "s/CREATE SCHEMA/-- &/" \
	> ${ddl}

psql -a -d ${db_name} -f $ddl

psql -a -d ${db_name} -c "select * from ${ext};"

rm ${ddl}
