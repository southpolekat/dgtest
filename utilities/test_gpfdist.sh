#!/bin/bash

db=dgtest$$
createdb $db

# hostname
sdw1=sdw1
sdw2=sdw2

### prepare testing directory and data
gpssh -f ~/hostfile 'mkdir -p /tmp/dgtest'
gpssh -h $sdw1 'echo "1,a" > /tmp/dgtest/1.csv'
gpssh -h $sdw2 'echo "2,b" > /tmp/dgtest/2.csv'

### run gpfdist on segment hosts
gpssh -f ~/hostfile '~/deepgreendb/bin/gpfdist -d /tmp/dgtest -p 8080 &'

psql -a -d $db <<END

create table tt (
    i   int,
    v   varchar)
distributed by (i);

create external table ext_tt (like tt)
location ('gpfdist://localhost:8080/*.csv')
format 'CSV';

insert into tt select * from ext_tt;

select * from tt;

END

gpssh -f ~/hostfile 'pkill gpfdist'
gpssh -f ~/hostfile 'rm -rf /tmp/dgtest'

dropdb $db
