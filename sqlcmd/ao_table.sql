create schema dgtest;

set search_path = dgtest;

drop table if exists tt_heap;   -- Normal heap table
drop table if exists tt_ao;     -- Append-only table
drop table if exists tt_ao_ct;  -- Append-only, compressed table
drop table if exists tt_ao_ct_col; -- Append-ony, compressed, column table

create table tt_heap ( i int, f float, t text)
    distributed by (i);
create table tt_ao (like tt_heap)
    with (appendonly=true)
    distributed by (i);
create table tt_ao_ct (like tt_heap)
    with (appendonly=true, compresstype=quicklz)
    distributed by (i);
create table tt_ao_ct_col (like tt_heap)
    with (appendonly=true, compresstype=quicklz, orientation=column)
    distributed by (i);

insert into tt_heap select i::int as i, i::float as f, 'text_' || i as t 
    from generate_series(1,1000) as i;
insert into tt_ao select i::int as i, i::float as f, 'text_' || i as t
    from generate_series(1,1000) as i;
insert into tt_ao_ct select i::int as i, i::float as f, 'text_' || i as t
    from generate_series(1,1000) as i;
insert into tt_ao_ct_col select i::int as i, i::float as f, 'text_' || i as t
    from generate_series(1,1000) as i;

analyze tt_heap;
analyze tt_ao;
analyze tt_ao_ct;
analyze tt_ao_ct_col;

select sotdtablename, sotdsize from gp_toolkit.gp_size_of_table_disk
where sotdschemaname = 'dgtest' order by sotdsize desc;

drop schema dgtest cascade;

