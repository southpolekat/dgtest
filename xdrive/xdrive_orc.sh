#!/bin/bash

db=dgtest$$
ddl=ext_tables.ddl

echo "---------- create $ddl"
cat <<END > $ddl
drop external table if exists ext_orc_write;
create writable external table ext_orc_write (
    id integer,
    name    text
) LOCATION ('xdrive://127.0.0.1:7171/local_orc/data_#SEGID#.orc')
FORMAT 'SPQ';
drop external table if exists ext_orc_read;
create external table ext_orc_read (
    id integer,
    name    text
) LOCATION ('xdrive://127.0.0.1:7171/local_orc/data_*.orc')
FORMAT 'SPQ';
END

echo "---------- create xdrive.toml"
cat <<END > /tmp/xdrive.toml
[xdrive]
dir = "/tmp/xdrive"
port = 7171
host = ["localhost"]

[[xdrive.mount]]
name = "local_orc"
argv = ["/usr/bin/java", "-Xmx1G", "-cp", "jars/vitessedata-file-plugin.jar",  "com.vitessedata.xdrive.orc.Main", "nfs", "/tmp"]

END

echo "---------- restart xdrive"
xdrctl stop /tmp/xdrive.toml
xdrctl deploy /tmp/xdrive.toml
xdrctl start /tmp/xdrive.toml

createdb $db
psql -d $db -f $ddl
psql -a -d $db << END
insert into ext_orc_write values (1,'a'), (2,'b'), (3,'c'), (4,'d');
select * from ext_orc_read;
select * from ext_orc_read where id = 1;
END
dropdb $db

xdrctl stop /tmp/xdrive.toml
rm $ddl /tmp/data_*.orc /tmp/xdrive.toml
