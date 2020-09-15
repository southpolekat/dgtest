#!/bin/bash

set -e 

source ../dgtest_env.sh

gpssh -h $sdw1 'echo "1,a" > /tmp/dgtest_1.csv'
gpssh -h $sdw1 'echo "2,b" > /tmp/dgtest_2.csv'
gpssh -h $sdw2 'echo "3,c" > /tmp/dgtest_3.csv'
gpssh -h $sdw2 'echo "4,d" > /tmp/dgtest_4.csv'

psql -a -d ${db_name} << END 
\set ON_ERROR_STOP true
DROP EXTERNAL TABLE IF EXISTS ${db_table};
CREATE EXTERNAL TABLE ${db_table} (id int,data varchar(1)) 
LOCATION ('FILE://$sdw1:40000/tmp/dgtest_1.csv',
          'FILE://$sdw1:40001/tmp/dgtest_2.csv',
          'FILE://$sdw2:40000/tmp/dgtest_3.csv',
          'FILE://$sdw2:40001/tmp/dgtest_4.csv'
          ) 
FORMAT 'CSV' (DELIMITER AS ','); 

SELECT gp_segment_id, * from ${db_table};

DROP EXTERNAL TABLE ${db_table};
END

gpssh -h ${sdw1} 'rm /tmp/dgtest*.csv'
gpssh -h ${sdw2} 'rm /tmp/dgtest*.csv'
