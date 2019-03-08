#!/bin/bash

db=dgtest$$

createdb $db

psql -a -d $db <<END 
create table tt as
    select i::bigint as i, i::double precision as f
    from generate_series(1, 100000) i
    distributed by (i);
END

set -x

### Analyze whole database
analyzedb -a -d $db 
### Analyze a table
analyzedb -a -d $db -t public.tt
### Analyze a column
analyzedb -a -d $db -t public.tt -i i

### -a : no prompt
### -d <database>
### -t <schema.table>
### -i <column>

### state files 
find $MASTER_DATA_DIRECTORY/db_analyze/$db/*

### remove last state files 
analyzedb -a -d $db --clean_last

### remove all state files
analyzedb -a -d $db --clean_all

dropdb $db
