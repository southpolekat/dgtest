#!/bin/bash

db=dgtest$$
createdb $db

link=https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural
zip1=ne_10m_admin_0_countries.zip
zip2=ne_10m_populated_places.zip


if [ ! -f $zip1 ]; then
   wget $link/$zip1
   unzip -o $zip1
fi

if [ ! -f $zip2 ]; then
   wget $link/$zip2
   unzip -o $zip2
fi




dropdb $db

