#!/bin/bash
# Reference: https://gpdb.docs.pivotal.io/5170/ref_guide/extensions/pl_sql.html

set -x

db=dgtest$$

createdb $db

psql -a -d $db <<END
CREATE FUNCTION sales_tax(subtotal real) RETURNS real AS \$\$ 
BEGIN
   RETURN subtotal * 0.06;
END;
\$\$ LANGUAGE plpgsql;

\df+ sales_tax

SELECT sales_tax(100);

DROP FUNCTION sales_tax(real);
END

dropdb $db
