#!/bin/bash

bucket=vd-s3-tmp
path=/
s3pool_port=localhost
s3pool_host=8787

action=$(printf '["GLOB", "%s", "%s"]' $bucket $path)
echo ${action} | nc ${s3pool_port} ${s3pool_host}
