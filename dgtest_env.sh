#!/bin/bash

set -e

db_host=localhost
db_port=5432
db_name=dgtest
db_user=gpadmin
db_schema=public
db_table=dgtest_tt

loftd_host=mdw
loftd_path=/tmp/loftdata
loftd_port=8787

ver=$(psql -t -c "show vitesse.version" | cut -f4 -d ' ' | cut -f1 -d '.')
