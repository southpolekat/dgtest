#!/bin/bash

set -e

source ../dgtest_env.sh

f=/tmp/dgtest.sh

cat >$f <<END
#!/bin/bash
echo "1,a"
echo "2,b"
END

chmod 755 $f

psql -a -d ${db_name} << END 
\set ON_ERROR_STOP true
CREATE EXTERNAL WEB TABLE tt (id int,data varchar(1)) 
EXECUTE E'/tmp/dgtest.sh' on master
FORMAT 'CSV'; 

SELECT * from tt;
END

gpscp -f ~/hostfile $f =:$f
gpssh -f ~/hostfile chmod 755 $f

psql -a -d ${db_name} << END 
\set ON_ERROR_STOP true
CREATE EXTERNAL WEB TABLE tt2 (id int,data varchar(1)) 
EXECUTE E'/tmp/dgtest.sh' on host 
FORMAT 'CSV'; 

SELECT * from tt2;
END

rm $f 
gpssh -f ~/hostfile rm $f
