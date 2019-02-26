#!/bin/bash

db=dgtest$$
createdb $db

sql=/tmp/dgtest$$.sql
echo "\timing on" > $sql

compresstypes=(none zlib zstd lz4)

for ct in ${compresstypes[*]} 
do
cat >> $sql  << EOF

\echo ========== Compress Type is $ct

create temp table tt_$ct (
    i int,
    t text,
    default column encoding (compresstype=${ct}))
    with (appendonly=true, orientation=column)
distributed by (i);

insert into tt_$ct select i, 'user '||i from generate_series(1, 1000000) i;

select sum(length(t)) from tt_$ct;

select pg_size_pretty(pg_relation_size('tt_$ct'));

EOF
done

psql -d $db -f $sql

dropdb $db
rm $sql
