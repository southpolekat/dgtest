#!/bin/bash

set -e 

db=dgtest

if [ -f $GPHOME/share/postgresql/contrib/json.sql ];
then
        psql $db -f $GPHOME/share/postgresql/contrib/json.sql
fi

cat << EOF > /tmp/sample$$.json
{ "id": 1, "type": "home", "address": { "city": "Boise", "state": "Idaho" } }
{ "id": 2, "type": "fax", "address": { "city": "San Francisco", "state": "California" } }
{ "id": 3, "type": "cell", "address": { "city": "Chicago", "state": "Illinois" } }
EOF

psql -a -d $db << EOF

\set ON_ERROR_STOP true

create temp table jj ( j json) distributed randomly;
\copy jj from '/tmp/sample.json';

select * from jj;

create temp table tt as 
select 
(j->>'id')::int as id,
j->>'type' as type, 
j->'address'->>'city' as city,
j->'address'->>'state' as state 
from jj;

\d+ tt

select * from tt;

EOF

rm /tmp/sample$$.json
