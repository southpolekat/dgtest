#!/bin/bash
  
db=dgtest$$
fi=/tmp/dgtest$$_in.csv
fo=/tmp/dgtest$$_out.csv

createdb $db

cat <<END >> $fi
beer,50
coffee,30
tea,20
END

psql -a -d $db << END

create table drinks (
    name text,
    price numeric 
)
distributed by (name);

COPY drinks FROM '$fi' DELIMITER ',';

select * from drinks;

COPY drinks to '$fo' DELIMITER ',';

END

sort -o $fi $fi
sort -o $fo $fo

diff -s $fi $fo

rm -f $fi $fo

dropdb $db
