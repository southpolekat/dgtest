#!/bin/bash

db=dgtest$$

createdb $db

psql -a -d $db <<END
create table tt as 
select i::int as i, floor(random()*10+1) as r from generate_series(0,1000) i
distributed by (r);

select gp_segment_id, count(*) from tt group by (gp_segment_id);

alter table tt set distributed by (i);

select gp_segment_id, count(*) from tt group by (gp_segment_id);

END

dropdb $db
