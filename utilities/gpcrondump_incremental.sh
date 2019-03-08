#!/bin/bash

db=dgtest$$
dir=/tmp/dgtest_backupdir

createdb $db

psql -a -d $db << END
create table tt 
(i int, c varchar(1))
distributed by (i);

insert into tt (i,c) values (1,'a'), (2,'b');
END

gpcrondump -a -x $db -u $dir
### -a : no prompt
### -u <backup_directory>

psql $db -c "insert into tt (i,c) values (3,'c');"
gpcrondump -a -x $db -u $dir --incremental

psql $db -c "insert into tt (i,c) values (4,'d');"
gpcrondump -a -x $db -u $dir --incremental

psql -d $db -c "select * from gpcrondump_history ;"

ls -l $dir/db_dumps/$(date +%Y%m%d)

dropdb $db

#gpdbrestore -a -e -t <timestamp> --list-backup 
#gpdbrestore -a -e -t <timestamp> 
gpdbrestore -a -e -s $db -u $dir
### -a : no prompt
### -e : create target database before restore
### -s database_name

psql $db -c "select * from tt;"

rm -rf $dir

dropdb $db
