#!/bin/bash

db=dgtest$$
createdb $db

psql $db -f $GPHOME/share/postgresql/contrib/json.sql

psql -d $db << EOF

\echo Get JSON array element
select '[1,2,3]'::json->2;

\echo Get JSON array element as text
select '[1,2,3]'::json->>2, pg_typeof('[1,2,3]'::json->>2);

\echo Get JSON object field
select '{"a":1,"b":2}'::json->'b';

\echo Get JSON object field as text
select '{"a":1,"b":2}'::json->>'b';

\echo Get JSON object at specified path
select '{"a":[1,2,3],"b":[4,5,6]}'::json#>'{a,2}';

\echo Get JSON object at specified path as text
select '{"a":[1,2,3],"b":[4,5,6]}'::json#>>'{a,2}';

create temp table tt(i int, j json) distributed by (i);

insert into tt values (1,'[1,2,3]'), (2,'[4,5,6,7]');

select i,j,j->2,json_array_length(j) from tt;

EOF

dropdb $db

