#!/bin/bash

db=dgtest$$

createdb $db

dg setup -decimal $db

psql -d $db << EOF 

create table tt (
	i	integer,
	f	double precision,
	d64	decimal64,
	d128	decimal128,
	n	numeric(15, 3)
)
distributed by (i);

insert into tt select 
	i,
	(i+0.123)::double precision,
	(i+0.123)::decimal64,
	(i+0.123)::decimal128,
	(i+0.123)::numeric(15,3)
from generate_series(1,1000000) i;

\x
\timing on

set vitesse.enable=0;
select avg(f), sum(f) from tt;
select avg(n), sum(n) from tt;

set vitesse.enable=1;
select avg(f), sum(f) from tt;
select avg(n), sum(n) from tt;
select avg(d64), sum(d64) from tt;
select avg(d128), sum(d128) from tt;

EOF

dropdb $db
