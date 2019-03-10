#!/bin/bash
# Reference:
#   http://www.postgresqltutorial.com/postgresql-extract/
#   http://www.pivotalguru.com/?p=202
# Note: week is using ISO 8601, different from US

db=dgtest$$

createdb $db

psql -a -d $db <<END

CREATE TABLE date_dim
(
    date_key timestamp without time zone NOT NULL,
    day int not null,
    month int not null,
    year int not null,
    doy int not null,
    week int not null,
    quarter int not null,
    dow int not null
)
DISTRIBUTED BY (date_key);

insert into date_dim 
select d as date_key,
    extract('day' from d),
    extract('month' from d),
    extract('year' from d),
    extract('doy' from d),
    extract('week' from d),
    extract('quarter' from d),
    extract('dow' from d)
FROM (
    select '2000-01-01'::timestamp + 
        '1 day'::interval * generate_series(0, EXTRACT('days' from DATE 'today' - '2000-01-01'::timestamp)::int) as d
    ) as tmp;

select * from date_dim order by date_key limit 5;
END


dropdb $db
