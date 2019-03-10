create schema dgtest;

set search_path = dgtest;

create table tt (
    i int,
    a varchar )
distributed by (i);

create or replace function fn_update_tt() returns void as
$$
declare
    v_rowcount int;
begin
    insert into tt select i, i::text from generate_series(0,100) i;
    get diagnostics v_rowcount = ROW_COUNT;
    RAISE INFO '% Rows inserted.', v_rowcount;
    
    update tt set a = 'x' where i = 99;
    get diagnostics v_rowcount = ROW_COUNT;
    RAISE INFO '% Rows updated.', v_rowcount; 

    delete from tt where i = 99;
    get diagnostics v_rowcount = ROW_COUNT;
    RAISE INFO '% Rows deleted.', v_rowcount;
end;
$$
language plpgsql;

select fn_update_tt();

select count(*) from tt;

drop function fn_update_tt();
drop table tt; 
drop schema dgtest;
