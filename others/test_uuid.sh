#!/bin/bash

source ../dgtest_env.sh

psql -e -d ${db_name} << EOF
\set ON_ERROR_STOP true

--CREATE LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION gen_uuid ()
RETURNS VARCHAR(36)
AS \$$
import uuid
return str(uuid.uuid4())
\$$ LANGUAGE plpythonu;

CREATE TEMP TABLE ${db_table} (
    id uuid 
) distributed by (id);

INSERT INTO ${db_table} select gen_uuid()::uuid from generate_series(1,10);

SELECT * FROM ${db_table};
EOF
