/* sample.json
{ "id": 1, "type": "home", "address": { "city": "Boise", "state": "Idaho" } }
{ "id": 2, "type": "fax", "address": { "city": "San Francisco", "state": "California" } }
{ "id": 3, "type": "cell", "address": { "city": "Chicago", "state": "Illinois" } }
*/

create temp table jj ( j json);
\copy jj from 'sample.json';

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
