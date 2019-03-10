#!/bin/sh

db=dgtest$$
f=/tmp/dgtest.sh

createdb $db

cat >$f <<END
#!/bin/bash
echo "1,a"
echo "2,b"
END

chmod 755 $f

psql -a -d $db << END 
CREATE EXTERNAL WEB TABLE tt (id int,data varchar(1)) 
EXECUTE E'/tmp/dgtest.sh' on master
FORMAT 'CSV'; 

SELECT * from tt;
END

rm $f 

dropdb $db
