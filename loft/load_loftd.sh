#!/bin/bash

set -e

ver=$(../dg_major_version.sh)
[ $ver -ne "16" ] && exit

loft_port=${1:-8787}
loft_path=${2:-/tmp/loftdata}
clean_up=${3:-1}

db=dgtest
table=loft_table

./setup_loftd.sh ${loft_port} ${loft_path} 0

### create a temp table of testing
psql -a -d $db << EOF
create table ${table} (i int) distributed by (i);
insert into ${table} select i::int from generate_series(1,10) i;
select count(*) from ${table};
EOF

### load data to loft using pg2disk
schedfile=/tmp/schedfile
echo "test:src(localhost,5432,gpadmin,$db,public,$table):dst()::" > $schedfile
pg2disk -c -D ${loft_path}/base test $schedfile

### clean up
[ ${clean_up} -ne 1 ] && exit
psql -a -d $db -c "drop table ${table};"
pid=$(pidof loftd)
kill ${pid}
rm -rf ${loft_path}
rm ${schedfile}
rm -rf /tmp/pg2disk.*
