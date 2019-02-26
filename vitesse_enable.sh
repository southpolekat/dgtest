#!/bin/bash

db=dgtest$$

createdb $db

psql -a -d $db << EOF

show vitesse.version;

create table tt as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 1000000) i
    distributed by (i);

\timing on

set vitesse.enable=0;
select count(*), sum(i), avg(i) from tt;

set vitesse.enable=1;
select count(*), sum(i), avg(i) from tt;

EOF

dropdb $db
