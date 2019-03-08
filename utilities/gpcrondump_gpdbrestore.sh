#!/bin/bash

db=dgtest$$

createdb $db

psql -a -d $db << END

create table tt as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 1000) i
    distributed by (i);
select count(*), sum(i), avg(i) from tt;

END

gpcrondump -a -C --dump-stats -g -G -h -r -x $db

psql -d $db -c "select * from gpcrondump_history ;"

dropdb $db

gpdbrestore -a -e -s $db

psql $db -c "select count(*), sum(i), avg(i) from tt;"

dropdb $db


