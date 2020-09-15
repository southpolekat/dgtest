#!/bin/bash

set -e

source ../dgtest_env.sh

psql -a -d ${db_name} << EOF

\set ON_ERROR_STOP true

create temp table ${db_table} (
    i int,
    t text
)
distributed by (i);

insert into ${db_table} select i, 'text-'||i from generate_series(1, 100) i;

select * from ${db_table} limit sample 10 rows;

select * from ${db_table} limit sample 10 percent;

EOF
