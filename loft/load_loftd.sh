#!/bin/bash

set -e

source ../dgtest_env.sh

[ $ver -ne "16" ] && exit

### create a temp table of testing
psql -a -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop table if exists ${db_table};
create table ${db_table} (i int) distributed by (i);
insert into ${db_table} select i::int from generate_series(1,10) i;
select count(*) from ${db_table};
EOF

### load data to loft using pg2disk
schedfile=/tmp/schedfile
echo "test:src(${db_host},${db_port},${db_user},${db_name},${db_schema},${db_table}):dst()::" > $schedfile
pg2disk -c -D ${loftd_path}/base test $schedfile

rm $schedfile
