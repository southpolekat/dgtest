#!/bin/bash

set -e

db=dgtest

psql -a -d $db << EOF

\set ON_ERROR_STOP true

create temp table tt_sample (
    i int,
    t text
)
distributed by (i);

insert into tt_sample select i, 'text-'||i from generate_series(1, 100) i;

select * from tt_sample limit sample 10 rows;

select * from tt_sample limit sample 10 percent;

EOF
