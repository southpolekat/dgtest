/* sql script to test HBase intgeration

Run the following commands in Hbase to create the sample table 'contact'

create 'contact', 'name', 'address'
put 'contact', '1001', 'name:given', 'tom'
put 'contact', '1001', 'name:last', 'chan'
put 'contact', '1001', 'address:city', 'hong kong'
put 'contact', '1001', 'address:country', 'china'
put 'contact', '1002', 'name:given', 'sally'
put 'contact', '1002', 'name:last', 'Liu'
put 'contact', '1002', 'address:city', 'kuala lumpur'
put 'contact', '1002', 'address:country', 'Malaysia'
scan 'contact'

*/

DROP EXTERNAL TABLE IF EXISTS hbr;
CREATE EXTERNAL TABLE hbr(        
_row text,        
_column text,        
_value text,        
_timestamp bigint)
LOCATION ('xdrive://localhost:7171/hbase/contact')FORMAT 'SPQ';

\echo ValueFilter:binary
select * from hbr where 
dg_utils.xdrive_query($$column=name:last&ValueFilter=binary,eq,chan$$);

\echo ValueFilter:substring
select * from hbr where
dg_utils.xdrive_query($$column=name:given&ValueFilter=substring,eq,lly$$);

\echo ValueFilter:binary:ne
select * from hbr wherei
dg_utils.xdrive_query($$column=name:last&ValueFilter=binary,ne,xyz$$);

\echo startrow,stoprow
select * from hbr where
dg_utils.xdrive_query($$column=name:last&startrow=1002&stoprow=1002&ValueFilter=binary,ne,xyz$$);

\echo RowFilter:
select * from hbr where
dg_utils.xdrive_query($$RowFilter=binary,ne,$$);
select * from hbr where
dg_utils.xdrive_query($$RowFilter=binary,eq,1002$$);
select * from hbr where
dg_utils.xdrive_query($$column=name:last&RowFilter=binary,eq,1002$$);

\echo PageFilter: Return n number of rows
select * from hbr where
dg_utils.xdrive_query($$PageFilter=1$$);

\echo PrefixFilter: prefix of a row key
select * from hbr where
dg_utils.xdrive_query($$PrefixFilter=100$$);

\echo ColumnPrefixFilter: prefix of a column
select * from hbr where
dg_utils.xdrive_query($$ColumnPrefixFilter=ci$$);

\echo MultipleColumnPrefixFilter
select * from hbr where
dg_utils.xdrive_query($$MultipleColumnPrefixFilter=ci,co$$);

\echo InclusiveStopFilter
select * from hbr where
dg_utils.xdrive_query($$InclusiveStopFilter=1001$$);

\echo TimestampsFilter
select * from hbr where
dg_utils.xdrive_query($$TimestampsFilter=1569593810430,1569593810448$$);

\echo FamilyFilter
select * from hbr where                                                 
dg_utils.xdrive_query($$FamilyFilter=binary,eq,name$$);

\echo RandomRowFilter
select * from hbr where
dg_utils.xdrive_query($$RandomRowFilter=0.5$$);

\echo SingleColumnValueFilter & SingleColumnValueExcludeFilter
select * from hbr where
dg_utils.xdrive_query($$SingleColumnValueFilter=name:last,binary,eq,Liu$$);
select * from hbr where
dg_utils.xdrive_query($$SingleColumnValueExcludeFilter=name:last,binary,eq,Liu$$);

\echo timerange: endtime is exclusive 
select * from hbr where
dg_utils.xdrive_query($$timerange=1569593810430,1569593810487&PageFilter=10$$)

-- Not tested: ColumnPaginationFilter, KeyOnlyFilter, FirstKeyOnlyFilter,ColumnCountGetFilter,limit,offset
