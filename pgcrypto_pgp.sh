#!/bin/bash

# Manually create PGP keys
#   script /dev/null
#   gpg --gen-key
#       1 : RSA and RSA
#       1024 : keysize
#       0 : does not expire
#       y : correct
#       testing : real name
#       root@localhost : email
#       testing : comment
#       O : Okay
#       <empty> : keyphase
# Start another terminal and run
#       sudo dd if=/dev/sda of=/dev/zero


pubkey=$(gpg -a --export $1)
prikey=$(gpg -a --export-secret-keys $2)

db=dgtest$$

createdb $db

psql $db -f ~/deepgreendb/share/postgresql/contrib/pgcrypto.sql

psql -a -d $db << END

CREATE TABLE users(name varchar, data bytea) distributed randomly;

INSERT INTO users(name, data)
    SELECT tmp.name, pgp_pub_encrypt(tmp.data, keys.pubkey) As data
        FROM (VALUES ('a', '11'), ('b', '22')) As tmp(name, data)
            CROSS JOIN (SELECT dearmor('$pubkey') As pubkey) As keys;

SELECT pgp_key_id(dearmor('$pubkey'));

SELECT name, pgp_key_id(data) from users;    

SELECT name, pgp_pub_decrypt(data, keys.prikey) 
    FROM users CROSS JOIN
        (SELECT dearmor('$prikey') AS prikey) AS keys;

END

dropdb $db
