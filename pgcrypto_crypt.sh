#!/bin/bash

db=dgtest$$

createdb $db

psql $db -f ~/deepgreendb/share/postgresql/contrib/pgcrypto.sql

psql -a -d $db << END

CREATE TABLE users (
    id  int,
    pass1   text,
    pass2   text
) distributed by (id);

insert into users (id, pass1, pass2) values 
    (1, crypt('xxx',gen_salt('md5')), md5('xxx')),
    (2, crypt('xxx',gen_salt('md5')), md5('xxx')); 

select * from users;

select pass2 = md5('xxx') from users where id = 1;
select pass2 = md5('yyy') from users where id = 1;

select pass1 = crypt('xxx', pass1) from users where id = 1;
select pass1 = crypt('yyy', pass1) from users where id = 1;

END

dropdb $db
