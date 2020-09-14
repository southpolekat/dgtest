#!/bin/bash


db=dgtest

ver=$(psql -t -c "show vitesse.version" | cut -f4 -d ' ' | cut -f1 -d '.')

[ $ver -eq "16" ] && exit

psql -a -d $db << EOF

\set ON_ERROR_STOP true

create temp table paxtab (i bigint, f double precision)
    with (appendonly=true, compresstype=pax)
    distributed by (i);
create temp table coltab (i bigint, f double precision)
    with (appendonly=true, orientation=column, compresstype=lz4)
    distributed by (i);

\timing on

insert into paxtab select i, i from generate_series(1, 10000000) i;
insert into coltab select i, i from generate_series(1, 10000000) i;

select count(*) from paxtab;
select count(*) from coltab;

select sum(i), sum(f) from paxtab;
select sum(i), sum(f) from coltab;

select * from paxtab where i = 1000;
select * from coltab where i = 1000;

EOF
