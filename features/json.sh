#!/bin/bash

db=dgtest

if [ -f $GPHOME/share/postgresql/contrib/json.sql ];
then
	psql $db -f $GPHOME/share/postgresql/contrib/json.sql
fi

psql -a -d $db << EOF

\set ON_ERROR_STOP true

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

create temp table tt_json(i int, j json) distributed by (i);

insert into tt_json values (1,'[1,2,3]'), (2,'[4,5,6,7]');

select i,j,j->2,json_array_length(j) from tt_json;

EOF
