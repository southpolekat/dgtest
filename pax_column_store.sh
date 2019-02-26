#!/bin/bash

db=dgtest$$
createdb $db

psql -a -d $db << EOF

create table paxtab (i bigint, f double precision)
    with (appendonly=true, compresstype=pax)
    distributed by (i);
create table coltab (i bigint, f double precision)
    with (appendonly=true, orientation=column, compresstype=lz4)
    distributed by (i);

\timing on

insert into paxtab select i, i from generate_series(1, 10000000) i;
insert into coltab select i, i from generate_series(1, 10000000) i;

select count(*) from paxtab;
select count(*) from coltab;

select sum(i), sum(f) from paxtab;
select sum(i), sum(f) from coltab;

select * from paxtab where i = 1000000;
select * from coltab where i = 1000000;

EOF

dropdb $db
