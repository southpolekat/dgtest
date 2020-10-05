#!/bin/bash

set -e

# hostname of segment 1 and segment 2
sdw1=sdw1
sdw2=sdw2

db_host=localhost
db_port=5432
db_name=dgtest
db_user=gpadmin
db_schema=public
db_table=dgtest_tt
db_table2=dgtest_tt2
db_ext_table=dgtest_ext
db_ext_table2=dgtest_ext2

loftd_host=mdw
loftd_path=/tmp/loftdata
loftd_port=8787

loftd_host2=mdw
loftd_path2=/tmp/loftdata2
loftd_port2=8788

xdrive_port=7171
xdrive_path=/tmp/xdrive
xdrive_conf=/tmp/xdrive.toml
xdrive_data=/tmp/data

s3pool_port=12345
s3pool_path=/tmp/s3pool

hostfile=~/hostfile

ver=$(psql -t -c "show vitesse.version" | cut -f4 -d ' ' | cut -f1 -d '.')

function dglog {
	echo "##### [$(date +%T)] $@"
}
