#!/bin/bash
# Reference: http://www.pivotalguru.com/?p=871

set -x

db=dgtest
createdb $db

yml=/tmp/dgtest.yml
gen=/tmp/get_df.sh

cat > $yml <<END
---
VERSION: 1.0.0.1
TRANSFORMATIONS:
    transform_1:
        TYPE: input 
        CONTENT: data
        COMMAND: /bin/bash $gen
END

cat > $gen <<END
df -k | awk '{print \$1"|"\$2"|"\$3"|"\$4"|"\$5"|"\$6}' | tail -n +2
END

gpscp -f ~/hostfile $gen =:$gen
gpscp -f ~/hostfile $yml =:$yml

cat $yml

gpssh -f ~/hostfile  "source ~/deepgreendb/greenplum_path.sh; gpfdist -p 8999 -c $yml 2>&1 > /tmp/dgtest.log &"

psql -a -d $db <<END
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
END

### clean up
rm $yml $gen
gpssh -f ~/hostfile rm $yml $gen
gpssh -f ~/hostfile pkill -9 gpfdist

dropdb $db
