#!/bin/bash

source ../dgtest_env.sh

tmp_db=dgtest$$

dglog createdb ${tmp_db}
createdb ${tmp_db}

psql -a -d ${tmp_db} <<END 
create table tt as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 100000) i
    distributed by (i);
END

dglog Analyze whole database
analyzedb -a -d ${tmp_db} 

dglog  Analyze a table
analyzedb -a -d ${tmp_db} -t public.tt

dglog Analyze a column
analyzedb -a -d ${tmp_db} -t public.tt -i i

### -a : no prompt
### -d <database>
### -t <schema.table>
### -i <column>

dglog state files 
find $MASTER_DATA_DIRECTORY/db_analyze/${tmp_db}/*

dglog remove last state files 
analyzedb -a -d ${tmp_db} --clean_last

dglog remove all state files
analyzedb -a -d ${tmp_db} --clean_all

dglog dropdb ${tmp_db}
dropdb ${tmp_db}
