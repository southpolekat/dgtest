#!/bin/bash

set -e

source ../dgtest_env.sh

dglog Test string_agg
psql -a -d ${db_name} << END
CREATE TEMP table tmp (t text) distributed randomly;
INSERT INTO tmp values ('a'), ('b'), ('c');
SELECT string_agg(t) from tmp;
SELECT string_agg(t,'|') from tmp;
END

dglog Test LEFT and RIGHT
[ $ver -eq "16" ] && exit
psql -d ${db_name} -f ~/deepgreendb/share/postgresql/contrib/dgx.sql
psql -a -d ${db_name} << END
SELECT right('abcde',3);
SELECT left('abcde',3); 
END
