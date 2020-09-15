#!/bin/bash

set -e

source ../dgtest_env.sh

sql=/tmp/dgtest_compression.sql

echo "\timing on" > $sql
echo "\set ON_ERROR_STOP true" >> $sql

compresstypes=(none zlib zstd lz4)
max=1000000

for ct in ${compresstypes[*]} 
do
cat >> $sql  << EOF


create temp table tmp_table_$ct (
    i int,
    t text,
    default column encoding (compresstype=${ct}))
    with (appendonly=true, orientation=column)
distributed by (i);

insert into tmp_table_$ct select i, 'user '||i from generate_series(1, $max) i;

select sum(i), sum(length(t)) from tmp_table_$ct;

select pg_size_pretty(pg_relation_size('tmp_table_$ct'));

EOF
done

psql -a -d ${db_name} -f $sql

rm $sql
