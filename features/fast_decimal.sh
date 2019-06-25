#!/bin/bash

db=dgtest$$

createdb $db

dg setup -decimal $db

psql -a -d $db << EOF 

set vitesse.enable=1;

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

select count(*) from tt;

\timing on

select avg(f), sum(2*f) from tt;
select avg(d64), sum(2*d64) from tt;
select avg(d128), sum(2*d128) from tt;
select avg(n), sum(2*n) from tt;

set vitesse.enable=0;
select avg(n), sum(2*n) from tt;

EOF

dropdb $db
