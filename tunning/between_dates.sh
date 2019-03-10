#!/bin/bash
# Improve BETWEEN statement by using generate_series
# Reference: http://www.pivotalguru.com/?p=199

db=dgtest$$
createdb $db

psql -a -d $db <<END

create table a (
    d  timestamp
) distributed by (d);

create table b (
    i int,
    start_d timestamp,
    end_d timestamp
) distributed by (i); 

-- Generate some data 
insert into a select DATE 'today' + interval'1 day' * trunc(random() * 365) from generate_series(0, 10000) i;
insert into b select i, DATE 'today' + interval'1 day'*i, DATE 'today' +interval'1 day'*i+interval'5 days' from generate_series(0, 10000) i;

\timing on
create table y as select a.d, b.i from a join b on a.d between b.start_d and b.end_d distributed by (i);
create table z as select a.d, c.i from (select *, start_d + interval '1 day' * (generate_series(0, (EXTRACT('days' FROM end_d - start_d)::int))) AS d from b ) as c join a on c.d = a.d distributed by (i);

END

dropdb $db




