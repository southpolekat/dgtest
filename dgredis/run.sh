#!/bin/bash

set -e

# sudo apt install redis-server

PGDATABASE=tpch dgredis dgredis.toml

echo "GET s:active" | redis-cli -h redis1
echo "GET s:timestamp" | redis-cli -h redis1
echo "LRANGE c:table 0 -1" |  redis-cli -h redis1
echo "GET t:orders:1" | redis-cli -h redis1

dgredis_get -h redis1:6379 "t:orders:1"
