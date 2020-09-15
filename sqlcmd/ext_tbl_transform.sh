#!/bin/bash
# Reference: http://www.pivotalguru.com/?p=871

set -e

source ../dgtest_env.sh

yml=/tmp/dgtest.yml
gen=/tmp/get_df.sh

cat > $yml <<EOF
---
VERSION: 1.0.0.1
TRANSFORMATIONS:
    transform_1:
        TYPE: input 
        CONTENT: data
        COMMAND: /bin/bash $gen
EOF

cat > $gen <<EOF
df -k | awk '{print \$1"|"\$2"|"\$3"|"\$4"|"\$5"|"\$6}' | tail -n +2
EOF

gpscp -f ~/hostfile $gen =:$gen
gpscp -f ~/hostfile $yml =:$yml

gpssh -f ~/hostfile  "source ~/deepgreendb/greenplum_path.sh; gpfdist -p 8999 -c $yml 2>&1 > /tmp/gpfdist.log &"

psql -a -d ${db_name} <<EOF
\set ON_ERROR_STOP true
CREATE EXTERNAL TABLE get_df 
(Filesystem text,
 K_blocks int,
 Used int,
 Available int,
 Used_percentage text,
 Mounted_on text)
LOCATION ('gpfdist://127.0.0.1:8999/foo#transform=transform_1')
FORMAT 'TEXT' (DELIMITER '|');

SELECT * from get_df;
DROP EXTERNAL TABLE get_df;
EOF

### clean up
rm $yml $gen
gpssh -f ~/hostfile pkill -9 gpfdist
gpssh -f ~/hostfile rm $yml $gen /tmp/gpfdist.log
