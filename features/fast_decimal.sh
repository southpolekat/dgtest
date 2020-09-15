#!/bin/bash

set -e

source ../dgtest_env.sh

dg setup -decimal ${db_name}

psql -a -d ${db_name} << EOF 

\set ON_ERROR_STOP true

create temp table ${db_table} (
	i	integer,
	f	double precision,
	d64	decimal64,
	d128	decimal128,
	n	numeric(15, 3)
)
distributed by (i);

insert into ${db_table} select 
	i,
	(i+0.123)::double precision,
	(i+0.123)::decimal64,
	(i+0.123)::decimal128,
	(i+0.123)::numeric(15,3)
from generate_series(1,1000000) i;

select count(*) from ${db_table};

\timing on

select avg(f), sum(2*f) from ${db_table};
select avg(d64), sum(2*d64) from ${db_table};
select avg(d128), sum(2*d128) from ${db_table};
select avg(n), sum(2*n) from ${db_table};

EOF
