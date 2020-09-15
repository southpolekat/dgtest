#!/bin/bash

set -e

db_host=localhost
db_port=5432
db_name=dgtest
db_user=gpadmin
db_schema=public
db_table=dgtest_tt
db_table2=dgtest_tt2

loftd_host=mdw
loftd_path=/tmp/loftdata
loftd_port=8787

loftd_host2=mdw
loftd_path2=/tmp/loftdata2
loftd_port2=8788

# hostname of segment 1 and segment 2
sdw1=sdw1
sdw2=sdw2

ver=$(psql -t -c "show vitesse.version" | cut -f4 -d ' ' | cut -f1 -d '.')
