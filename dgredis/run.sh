#!/bin/bash

# sudo apt install redis-server

PGDATABSE=tpch dgredis dgredis.toml

dgredis_get -h redis1:6379 "t:orders:1"
