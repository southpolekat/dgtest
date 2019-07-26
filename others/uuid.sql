create schema dgtest;
set search_path = dgtest;

CREATE TABLE contacts (
    id uuid ,
    name VARCHAR NOT NULL
) distributed by (id);

insert into contacts values ('40e6215d-b5c6-4896-987c-f30f3678f608', 'Andy');
insert into contacts values ('6ecd8c99-4036-403d-bf84-cf8400f67836', 'Billy');

select * from contacts;

DROP SCHEMA dgtest cascade;
