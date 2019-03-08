#!/bin/bash

db=dgtest$$
createdb $db

### Create xdrive config file
cat <<END > /tmp/xdrive.toml 
[xdrive]
dir = "/tmp/xdrive"
port = 7171 
host = ["sdw1"]

[[xdrive.mount]]
name = "local_csv"
argv = ["xdr_fs/xdr_fs", "csv", "/tmp/data"]
END

gpssh -h sdw1 'pkill -9 xdrive'
gpssh -h sdw2 'pkill -9 xdrive'

xdrctl deploy /tmp/xdrive.toml
xdrctl start /tmp/xdrive.toml

gpssh -h sdw1 'mkdir -p /tmp/data'
gpssh -h sdw1 'echo "1,1.99" | tee /tmp/data/xdrive_1.csv' 
gpssh -h sdw1 'echo "2,2.99" | tee /tmp/data/xdrive_2.csv'

psql -d $db << END
CREATE EXTERNAL TABLE tt_r
(
    i int,
    f double precision
)
LOCATION ('xdrive://127.0.0.1:7171/local_csv/xdrive_*.csv') 
FORMAT 'CSV';
SELECT * FROM tt_r;
END

xdrctl stop /tmp/xdrive.toml
dropdb $db
