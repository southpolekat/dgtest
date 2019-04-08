#!/bin/bash

# Get the AWS access key from https://console.aws.amazon.com/iam/home?#/security_credentials
# Create ~/.aws/credentials 

db=dgtest$$
createdb $db

bucket=vd-tmp
region=us-east-1
folder=/data

### Create xdrive config file
cat <<END > /tmp/xdrive.toml 
[xdrive]
dir = "/tmp/xdrive"
port = 7171 
host = ["sdw1", "sdw2"]

[[xdrive.mount]]
name = "s3"
argv = ["xdr_s3/xdr_s3", "csv", "$bucket", "$region", "", "$folder"]
END

gpssh -h sdw1 'pkill -9 xdrive'
gpssh -h sdw2 'pkill -9 xdrive'

xdrctl deploy /tmp/xdrive.toml
xdrctl start /tmp/xdrive.toml
gpssh -f ~/hostfile pidof xdrive

psql -d $db << END

CREATE WRITABLE EXTERNAL TABLE tt_w
(
    i int,
        f double precision
        )
LOCATION ('xdrive://127.0.0.1:7171/s3/xdrive_#SEGID#.csv') 
FORMAT 'CSV';

insert into tt_w (i,f) select i::int, i::float from generate_series(1,10) i;

CREATE EXTERNAL TABLE tt_r
(
    i int,
    f double precision
)
LOCATION ('xdrive://127.0.0.1:7171/s3/xdrive_*.csv') 
FORMAT 'CSV';

select * from tt_r;

END

xdrctl stop /tmp/xdrive.toml
dropdb $db
