#!/bin/bash
# Reference: ht1p://www.pivotalguru.com/?p=101

set -x

db=dgtest$$

createdb $db

psql -a $db <<END

show gp_default_storage_options ;

CREATE TABLE tt (
    i int,
    f float,
    t text)
DISTRIBUTED BY (i)
partition by range(i)
( START (1) INCLUSIVE END (5000) INCLUSIVE with (appendonly=true, orientation=column, compresstype=zlib, compresslevel=5),
  START (5001) INCLUSIVE END (10000) INCLUSIVE with (appendonly=true, orientation=column, compresstype=quicklz),
DEFAULT PARTITION extra);

insert into tt select i::int, i::float, i::text from generate_series(1,15000) i; 

select count(*) from tt_1_prt_extra;
select count(*) from tt_1_prt_2;
select count(*) from tt_1_prt_3;

select pg_size_pretty(pg_relation_size('tt_1_prt_extra'));
select pg_size_pretty(pg_relation_size('tt_1_prt_2'));
select pg_size_pretty(pg_relation_size('tt_1_prt_3'));

END

dropdb $db
