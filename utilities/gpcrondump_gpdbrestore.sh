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
### -a : no prompt
### -C : clean catalog before restore
### -g : copy config files
### -G : dump global objects
### -h : record dump details
### -r : rollback on failure

psql -d $db -c "select * from gpcrondump_history ;"

dropdb $db

gpdbrestore -a -e -s $db
### -a : no prompt
### -e : create target database before restore
### -s database_name

psql $db -c "select count(*), sum(i), avg(i) from tt;"

dropdb $db


