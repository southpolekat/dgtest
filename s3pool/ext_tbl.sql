DROP EXTERNAL TABLE IF EXISTS ext;

CREATE EXTERNAL TABLE ext (
   i int
)
LOCATION ( 'xdrive://localhost:7171/vd-s3-tmp/*.csv') 
FORMAT 'csv';

select * from ext;

