#!/bin/bash
# Reference: http://vitessedata.com/blog/postgres-compare-table/

db=dgtest$$
createdb $db

psql -a -d $db <<END

create table t1 (i int, f float) distributed by (i);
insert into t1 select i, i::float+0.123 from generate_series(1,100) i;

create table t2 as (select * from t1) distributed by (i);
update t2 set f=2.222 where i = 99;

-- rows missing in t2
select * from t1 except select * from t2;

-- rows missing in t1
select * from t2 except select * from t1;

-- rows different between t1 and t2
select * 
from (
    (select * from t1 except select * from t2)
        union all (select * from t2 except select * from t1)) foo;

-- 
with A as (
    select hashtext(textin(record_out(t1))) as h, count(*) as c
      from t1
      group by 1
),
 B as (
    select hashtext(textin(record_out(t2))) as h, count(*) as c
    from t2
    group by 1
)
select *
 from A full outer join B on (A.h + A.c = B.h + B.c)
 where A.h is null or B.h is null;

--
select h, sum(cnt) from (
   select textin(record_out(t1)) as h, 1 as cnt from t1
   union all
   select textin(record_out(t2)) as h, -1 as cnt from t2) foo
group by h 
having sum(cnt) <> 0;

END

dropdb $db
