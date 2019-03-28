create schema dgtest;
set search_path = dgtest;

show gp_autostats_mode;
show gp_autostats_on_change_threshold;

create table tt as
select i::int as i, i::float as f
from generate_series(1,100) i
distributed by (i);

select * from pg_stat_operations where objname = 'tt';

insert into tt (i,f) values (101, 101);
select * from pg_stat_operations where objname = 'tt';

set gp_autostats_mode = 'ON_CHANGE';
set gp_autostats_on_change_threshold = 1;

insert into tt (i,f) values (102, 102), (103, 104);
select * from pg_stat_operations where objname = 'tt';

drop schema dgtest cascade;
