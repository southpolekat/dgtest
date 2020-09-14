#!/bin/bash

set -e

ver=$(../dg_major_version.sh)

[ $ver -eq "16" ] && exit

db=dgtest

# Install LEFT and RIGHT function

psql -d $db -f ~/deepgreendb/share/postgresql/contrib/dgx.sql

psql -a -d $db << END

SELECT right('abcde',3);
SELECT left('abcde',3); 

END
