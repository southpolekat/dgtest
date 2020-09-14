#!/bin/bash

set -e

db=dgtest

sql=/tmp/dgtest_compression.sql

echo "\timing on" > $sql

compresstypes=(none zlib zstd lz4)
max=1000000

for ct in ${compresstypes[*]} 
do
cat >> $sql  << EOF

\set ON_ERROR_STOP true

create temp table tt_$ct (
    i int,
    t text,
    default column encoding (compresstype=${ct}))
    with (appendonly=true, orientation=column)
distributed by (i);

insert into tt_$ct select i, 'user '||i from generate_series(1, $max) i;

select sum(i), sum(length(t)) from tt_$ct;

select pg_size_pretty(pg_relation_size('tt_$ct'));

EOF
done

psql -a -d $db -f $sql

rm $sql
