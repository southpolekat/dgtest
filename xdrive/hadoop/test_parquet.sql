DROP EXTERNAL TABLE IF EXISTS ext_parquet_w;
DROP EXTERNAL TABLE IF EXISTS ext_parquet_r;

CREATE WRITABLE EXTERNAL TABLE ext_parquet_w (i int, t text)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_parquet/xdrive_#SEGID#.parquet') 
FORMAT 'CSV';

CREATE EXTERNAL TABLE ext_parquet_r (i int, t text)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_parquet/xdrive_*.parquet') 
FORMAT 'CSV';

\timing

insert into ext_parquet_w (i,t) 
select i::int, 'parquet-'||i from generate_series(1,1000000) i;

select count(*) from ext_parquet_r;

select * from ext_parquet_r order by i limit 10;
