#!/bin/bash

set -e

source ../dgtest_env.sh

[ $ver -ne "16" ] && exit

[ $(pidof -s loftd) ] && kill $(pidof loftd) 

mkdir -p ${loftd_path}

echo "port=${loftd_port}" > ${loftd_path}/loftd.conf

loftd -D $loftd_path
