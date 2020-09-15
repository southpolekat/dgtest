#!/bin/bash

source ./dgtest_env.sh 

psql -a -d ${db_name} << EOF

create temp table ${db_table} as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 1000000) i
    distributed by (i);

\timing on

set vitesse.enable=0;
select count(*), sum(i), avg(i) from ${db_table};

set vitesse.enable=1;
select count(*), sum(i), avg(i) from ${db_table};

EOF
