-- Reference: https://community.pivotal.io/s/article/Script---Database-Locks

-- Summary of the waiting process
select  
    (select datname from pg_database where oid=l.database) as database,
    locktype,
    relation::regclass,
    count(*)
from pg_locks l
where not l.granted
group by 1,2,3;

-- Lock information where LockType = "Relation"
select
    d.datname,
    c.relname,
    l.locktype,
    l.pid,
    l.mode,
    s.usename,
    s.query_start,
    s.current_query
from
    pg_locks l,
    pg_stat_activity s,
    pg_database d,
    pg_class c
where
    l.database = d.oid and
    l.pid = s.procpid and
    l.relation = c.oid and
    not l.granted;
