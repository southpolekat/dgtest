#!/bin/bash

db=dgtest$$
createdb $db

#export LD_LIBRARY_PATH=$GPHOME/lib/

echo $GPHOME
echo $LD_LIBRARY_PATH

psql -a -d $db -f $GPHOME/share/postgresql/pljava/install.sql 

psql -a -d $db -c "show pljava_classpath;"

dropdb $db


