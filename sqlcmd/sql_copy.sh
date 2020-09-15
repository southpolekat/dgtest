#!/bin/bash

set -e

source ../dgtest_env.sh
  
fi=/tmp/dgtest$$_in.csv
fo=/tmp/dgtest$$_out.csv

cat <<EOF >> $fi
beer,50
coffee,30
tea,20
EOF

psql -a -d ${db_name} << EOF
\set ON_ERROR_STOP true

create temp table drinks (
    name text,
    price numeric 
)
distributed by (name);

COPY drinks FROM '$fi' DELIMITER ',';

select * from drinks;

COPY drinks to '$fo' DELIMITER ',';

EOF

sort -o $fi $fi
sort -o $fo $fo

diff -s $fi $fo

rm -f $fi $fo
