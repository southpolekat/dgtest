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

