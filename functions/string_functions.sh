#!/bin/bash

db=dgtest$$

createdb $db

# Install LEFT and RIGHT function
psql -d $db -f ~/deepgreendb/share/postgresql/contrib/dgx.sql

psql -a -d $db << END

SELECT right('abcde',3);
SELECT left('abcde',3); 

END

dropdb $db
