DROP EXTERNAL TABLE IF EXISTS tt_w;
DROP EXTERNAL TABLE IF EXISTS tt_r;

CREATE WRITABLE EXTERNAL TABLE tt_w
(
    i int,
    f double precision
)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_csv/xdrive_#SEGID#.csv') 
FORMAT 'CSV';

insert into tt_w (i,f) select i::int, i::float from generate_series(1,10) i;

CREATE EXTERNAL TABLE tt_r
(
    i int,
    f double precision
)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_csv/xdrive_#SEGID#.csv') 
FORMAT 'CSV';

select * from tt_r;
