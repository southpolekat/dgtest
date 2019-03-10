#!/bin/bash

db=dgtest

createdb $db

psql -a -d $db << END

create schema dgtest;

set search_path = dgtest;

create table a as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 100) i
    distributed by (i);

create table b as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 100) i
    distributed by (i);

END

psql -A -t -d $db -c "select 'ANALYZE ' || table_schema || '.' || table_name || ';' from information_schema.tables where table_schema = 'dgtest';" | psql -a -d $db  

dropdb $db
