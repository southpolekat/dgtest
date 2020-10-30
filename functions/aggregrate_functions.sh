#!/bin/bash

source ../dgtest_env.sh

psql -a -d ${db_name} << END
\set ON_ERROR_STOP true

CREATE TEMP TABLE tmp (i int) distributed by (i);
INSERT INTO tmp select i::int from generate_series(1,10) i;

SELECT AVG(i) FROM tmp;

END
