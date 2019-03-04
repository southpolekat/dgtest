#!/bin/bash

db=dgtest$$
createdb $db

### Create xdrive config file
cat <<EOF > /tmp/xdrive.toml 
[xdrive]
dir = "/tmp/xdrive"
port = 7171 
host = ["sdw1", "sdw2" ]

[[xdrive.mount]]
name = "local_csv"
argv = ["xdr_fs/xdr_fs", "csv", "/tmp/data"]
EOF

xdrctl stop /tmp/xdrive.toml
xdrctl deploy /tmp/xdrive.toml
xdrctl start /tmp/xdrive.toml

gpssh -h sdw1 'mkdir -p /tmp/data'
gpssh -h sdw2 'mkdir -p /tmp/data'

gpssh -h sdw1 'echo "1,1.99" | tee /tmp/data/xdrive_1.csv' 
gpssh -h sdw1 'echo "2,2.99" | tee /tmp/data/xdrive_2.csv'
gpssh -h sdw2 'echo "3,3.99" | tee /tmp/data/xdrive_3.csv' 
gpssh -h sdw2 'echo "4,4.99" | tee /tmp/data/xdrive_4.csv'

psql -d $db << EOF
CREATE EXTERNAL TABLE tt_r
(
    i int,
    f double precision
)
LOCATION ('xdrive://127.0.0.1:7171/local_csv/xdrive_*.csv') 
FORMAT 'CSV';
SELECT * FROM tt_r;
EOF

xdrctl stop /tmp/xdrive.toml
dropdb $db
