#!/bin/bash

source ../dgtest_env.sh

[ $ver -eq "16" ] && exit

./xdr_fs.sh parquet
