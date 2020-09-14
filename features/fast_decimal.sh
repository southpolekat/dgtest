#!/bin/bash

db=dgtest

dg setup -decimal $db

psql -a -d $db << EOF 

create temp table tt_decimal (
	i	integer,
	f	double precision,
	d64	decimal64,
	d128	decimal128,
	n	numeric(15, 3)
)
distributed by (i);

insert into tt_decimal select 
	i,
	(i+0.123)::double precision,
	(i+0.123)::decimal64,
	(i+0.123)::decimal128,
	(i+0.123)::numeric(15,3)
from generate_series(1,1000000) i;

select count(*) from tt_decimal;

\timing on

select avg(f), sum(2*f) from tt_decimal;
select avg(d64), sum(2*d64) from tt_decimal;
select avg(d128), sum(2*d128) from tt_decimal;
select avg(n), sum(2*n) from tt_decimal;

EOF
