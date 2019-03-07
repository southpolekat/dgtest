#!/bin/bash

db=dgtest$$

createdb $db

psql $db -f ~/deepgreendb/share/postgresql/contrib/pgcrypto.sql

dropdb $db
