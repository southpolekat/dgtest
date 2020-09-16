#!/bin/bash

set -e

source ../dgtest_env.sh

[ $(pidof -s loftd) ] && kill $(pidof loftd) 

psql -a -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop table if exists ${db_table};
drop table if exists ${db_table2};
drop external table if exists ${db_ext_table};
drop external table if exists ${db_ext_table2};
EOF

rm -rf ${loftd_path}
rm -rf ${loftd_path2}

rm -f /tmp/pg2disk*
