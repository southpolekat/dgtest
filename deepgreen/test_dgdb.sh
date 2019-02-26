#!/bin/bash

function info {
   echo "[INFO] $@"
}

pwd=$(pwd)

db=db_$$
tb=tb_$$

info createdb $db
createdb $db

psql -d $db -c "show vitesse.version;"

info create table $tb 
psql -d $db -c "create table $tb as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 1000000) i
    distributed by (i);"

info set vitesse.enable=0 and test
psql -d $db << EOF
set vitesse.enable=0;
\timing on
select count(*), sum(i), avg(i) from $tb;
EOF

info set vitesse.enable=1 and test
psql -d $db << EOF
set vitesse.enable=1;
\timing on
select count(*), sum(i), avg(i) from $tb;
EOF

info dropdb $db
dropdb $db
