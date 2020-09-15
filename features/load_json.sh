#!/bin/bash

set -e 

source ../dgtest_env.sh

if [ -f $GPHOME/share/postgresql/contrib/json.sql ];
then
        psql ${db_name} -f $GPHOME/share/postgresql/contrib/json.sql
fi

cat << EOF > /tmp/sample$$.json
{ "id": 1, "type": "home", "address": { "city": "Boise", "state": "Idaho" } }
{ "id": 2, "type": "fax", "address": { "city": "San Francisco", "state": "California" } }
{ "id": 3, "type": "cell", "address": { "city": "Chicago", "state": "Illinois" } }
EOF

psql -a -d ${db_name} << EOF

\set ON_ERROR_STOP true

create temp table jj ( j json) distributed randomly;
\copy jj from '/tmp/sample$$.json';

select * from jj;

create temp table ${db_table} as 
select 
(j->>'id')::int as id,
j->>'type' as type, 
j->'address'->>'city' as city,
j->'address'->>'state' as state 
from jj;

\d+ ${db_table}

select * from ${db_table};

EOF

rm /tmp/sample$$.json
