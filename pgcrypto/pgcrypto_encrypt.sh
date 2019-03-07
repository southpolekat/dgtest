#!/bin/bash

db=dgtest$$

createdb $db

psql $db -f ~/deepgreendb/share/postgresql/contrib/pgcrypto.sql

psql -a -d $db << END

-- set bytea_output = 'escape';
select encrypt('abcde', 'mykey', 'aes');
select decrypt('!\006\277\177\276I\024WHR\235oa\013V\363', 'mykey', 'aes');
select encrypt('abcde', 'mykey', 'bf');
select decrypt('\212\242\256\252\205T\203u', 'mykey', 'bf');

create table customers (name bytea) distributed randomly;
insert into customers (name) values (encrypt('abcde','mykey','aes'));
select decrypt(name,'mykey','aes') from customers;

-- set bytea_output = 'hex';
-- select encrypt('abcde', 'mykey', 'aes');
-- set bytea_output = 'escape';
-- select decrypt(decode('2106bf7fbe49145748529d6f610b56f3','hex'), 'mykey', 'aes');

END

dropdb $db
