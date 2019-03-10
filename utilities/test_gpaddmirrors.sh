#!/bin/bash

dir=/data/mirror
cfg=/tmp/mirror_dir.cfg

cat > $cfg <<END
$dir
$dir
END

gpaddmirrors -a -m $cfg

rm $cfg



