#!/bin/sh

db=dgtest$$

gpssh -h sdw1 'echo "1,a" > /tmp/dgtest_1.csv'
gpssh -h sdw1 'echo "2,b" > /tmp/dgtest_2.csv'

createdb $db

psql -a -d $db << END 
CREATE EXTERNAL TABLE tt (id int,data varchar(1)) 
LOCATION ('FILE://sdw1:40000/tmp/dgtest_1.csv',
          'FILE://sdw1:40001/tmp/dgtest_2.csv') 
FORMAT 'CSV' (DELIMITER AS ','); 

SELECT gp_segment_id, * from tt;
END

gpssh -f ~/hostfile 'rm /tmp/dgtest*.csv'

dropdb $db

