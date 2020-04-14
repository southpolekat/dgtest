#!/bin/bash

bucket=vd-s3-tmp

s3pool_exec=~/p/s3pool/bin/s3pool
s3pool_host=localhost
s3pool_port=8787
s3pool_path=/data/s3pool_cache

#pid=$(pidof s3pool)

if [ ! -z "$pid" ]; then
   kill -9 $pid
fi

#rm -rf ${s3pool_path}
#mkdir ${s3pool_path}

${s3pool_exec} -p ${s3pool_port} -D ${s3pool_path} &

f=s3pool.csv

function op() {
   echo $@
   echo $@ | nc ${s3pool_host} ${s3pool_port}
}

#op '["STATUS"]'

op $(printf '["SET", "verbose", "9"]')
#op $(printf '["SET", "refresh_interval", "3"]')
#op $(printf '["SET", "pull_concurrency", "5"]')

#op $(printf '["GLOB", "%s", "%s"]' $bucket $tmp)

echo "1" > /tmp/$f
op $(printf '["PUSH", "%s", "%s", "%s"]' $bucket $f /tmp/$f)
op $(printf '["REFRESH", "%s"]' $bucket)
op $(printf '["PULL", "%s", "%s"]' $bucket $f)
cat $s3pool_path/data/$bucket/$f

echo "2" >> /tmp/$f
op $(printf '["PUSH", "%s", "%s", "%s"]' $bucket $f /tmp/$f)
##op $(printf '["REFRESH", "%s"]' $bucket)
op $(printf '["PULL", "%s", "%s"]' $bucket $f)
cat $s3pool_path/data/$bucket/$f
