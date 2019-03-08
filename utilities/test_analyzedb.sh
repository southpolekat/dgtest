#!/bin/bash

db=dgtest$$

createdb $db

psql -a -d $db <<END 
create table tt as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 1000000) i
    distributed by (i);
END

dropdb $db
