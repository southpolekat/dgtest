#!/bin/bash

db=dgtest$$

createdb $db

psql -a -d $db << EOF

create temp table tt (
    i int,
    t text
)
distributed by (i);

insert into tt select i, 'text-'||i from generate_series(1, 100) i;

select * from tt limit sample 10 rows;

select * from tt limit sample 10 percent;

EOF

dropdb $db
