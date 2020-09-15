#!/bin/bash

set -e

ver=$(../dg_major_version.sh)
[ $ver -ne "16" ] && exit

loft_port=${1:-8787}
loft_path=${2:-/tmp/loftdata}
clean_up=${3:-1}

echo ${loft_port} ${loft_path} ${clean_up}

mkdir -p ${loft_path}

echo "port=${loft_port}" > ${loft_path}/loftd.conf

loftd -D $loft_path

[ $clean_up -ne 1 ] && exit

pid=$(pidof loftd)
kill $pid
rm -rf ${loft_path}
