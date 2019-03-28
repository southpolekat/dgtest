
create schema dgtest;
set search_path = dgtest;

show gp_select_invisible;

create table tt as
select i::int as i, i::float as f
from generate_series(1,5) i
distributed by (i);

select * from tt;

delete from tt;

select * from tt;

set gp_select_invisible = true;

-- seeing deleted rows
select * from tt;

-- nothing is updated
update tt set f = 0 where i = 1;

drop schema dgtest cascade;
    
