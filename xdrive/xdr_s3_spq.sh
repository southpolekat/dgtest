#!/bin/bash

# hostname of sdw1 and sdw2
sdw1=sdw1
sdw2=sdw2

db=dgtest
createdb $db

### Create xdrive config file
cat <<END > /tmp/xdrive.toml 
[xdrive]
dir = "/tmp/xdrive"
port = 7171 
host = ["$sdw1", "$sdw2"]

[[xdrive.xhost]]
name = "arrow"
bin = "xhost_arrow"

[[xdrive.mount]]
name = "s3"
argv = ["xdr_s3/xdr_s3", "spq", "vd-tmp", "us-east-1", "/tmp/", "/data"]
END

xdrctl stop /tmp/xdrive.toml
xdrctl deploy /tmp/xdrive.toml
xdrctl start /tmp/xdrive.toml
gpssh -f ~/hostfile pidof xdrive

psql -d $db << END
CREATE WRITABLE EXTERNAL TABLE tt_w
(
    i int,
    f double precision
)
LOCATION ('xdrive://127.0.0.1:7171/s3/xdrive_#SEGID#.spq') 
FORMAT 'SPQ';

insert into tt_w (i,f) select i::int, i::float from generate_series(1,10000) i;

CREATE EXTERNAL TABLE tt_r
(
    i int,
    f double precision
)
LOCATION ('xdrive://127.0.0.1:7171/s3/xdrive_*.spq') 
FORMAT 'SPQ';

SELECT gp_segment_id, count(*) FROM tt_r group by (gp_segment_id);

SELECT gp_segment_id, * FROM tt_r where i = 1; 

END

xdrctl stop /tmp/xdrive.toml
dropdb $db