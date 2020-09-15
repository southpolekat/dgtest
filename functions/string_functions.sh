#!/bin/bash

set -e

source ../dgtest_env.sh

[ $ver -eq "16" ] && exit

# Install LEFT and RIGHT function

psql -d ${db_name} -f ~/deepgreendb/share/postgresql/contrib/dgx.sql

psql -a -d ${db_name} << END

SELECT right('abcde',3);
SELECT left('abcde',3); 

END
