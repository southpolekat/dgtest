#!/bin/bash

set -e

source ../dgtest_env.sh

psql -a -d ${db_name} << EOF
\set ON_ERROR_STOP true

drop table if exists ${db_table}_heap;   -- Normal heap table
drop table if exists ${db_table}_ao;     -- Append-only table
drop table if exists ${db_table}_ao_ct;  -- Append-only, compressed table
drop table if exists ${db_table}_ao_ct_col; -- Append-ony, compressed, column table

create table ${db_table}_heap ( i int, f float, t text)
    distributed by (i);
create table ${db_table}_ao (like ${db_table}_heap)
    with (appendonly=true)
    distributed by (i);
create table ${db_table}_ao_ct (like ${db_table}_heap)
    with (appendonly=true, compresstype=quicklz)
    distributed by (i);
create table ${db_table}_ao_ct_col (like ${db_table}_heap)
    with (appendonly=true, compresstype=quicklz, orientation=column)
    distributed by (i);

insert into ${db_table}_heap select i::int as i, i::float as f, 'text_' || i as t 
    from generate_series(1,1000) as i;
insert into ${db_table}_ao select i::int as i, i::float as f, 'text_' || i as t
    from generate_series(1,1000) as i;
insert into ${db_table}_ao_ct select i::int as i, i::float as f, 'text_' || i as t
    from generate_series(1,1000) as i;
insert into ${db_table}_ao_ct_col select i::int as i, i::float as f, 'text_' || i as t
    from generate_series(1,1000) as i;

analyze ${db_table}_heap;
analyze ${db_table}_ao;
analyze ${db_table}_ao_ct;
analyze ${db_table}_ao_ct_col;

select sotdtablename, sotdsize from gp_toolkit.gp_size_of_table_disk
	where sotdtablename like '${db_table}%' order by sotdsize desc;

drop table ${db_table}_heap;
drop table ${db_table}_ao;
drop table ${db_table}_ao_ct;
drop table ${db_table}_ao_ct_col;

EOF
