#!/bin/bash

set -e

source ../dgtest_env.sh

[ $ver -ne "16" ] && exit

psql ${db_name} -f $GPHOME/share/postgresql/contrib/vitesse.sql

ddl=/tmp/${db_table}.xql

cat ${loftd_path}/base/${db_name}/${db_schema}/${db_table}/*.xsql \
	| sed -e "s/\"${db_table}\"/\"${db_ext_table}\"/" \
	| sed -e "s/__LOFTD_ADDR__/${loftd_host}:${loftd_port}/" \
	| sed -e "s/CREATE SCHEMA/-- &/" \
	> ${ddl}

psql -a -d ${db_name} -f $ddl

psql -a -d ${db_name} -c "select * from ${db_ext_table};"

rm ${ddl}
