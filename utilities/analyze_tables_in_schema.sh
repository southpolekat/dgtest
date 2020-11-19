#!/bin/bash

source ../dgtest_env.sh

schema=test_schema

psql -a -d ${db_name} << END
\SET ON_ERROR_STOP ON 

CREATE SCHEMA ${schema};
SET SEARCH_PATH = ${schema};

DROP TABLE IF EXISTS a;
DROP TABLE IF EXISTS b;

create table a as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 100) i
    distributed by (i);

create table b as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 100) i
    distributed by (i);

END

psql -A -t -d ${db_name} -c "select 'ANALYZE ' || table_schema || '.' || table_name || ';' from information_schema.tables where table_schema = 'dgtest';" | psql -a -d ${db_name}  

psql -d ${db_name} -c "DROP SCHEMA ${schema} CASCADE;"
