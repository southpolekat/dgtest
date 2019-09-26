DROP EXTERNAL TABLE IF EXISTS ext_orc_w;
DROP EXTERNAL TABLE IF EXISTS ext_orc_r;

CREATE WRITABLE EXTERNAL TABLE ext_orc_w (i int, t text)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_orc/xdrive_#SEGID#.orc') 
FORMAT 'CSV';

CREATE EXTERNAL TABLE ext_orc_r (i int, t text)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_orc/xdrive_*.orc') 
FORMAT 'CSV';

\timing

insert into ext_orc_w (i,t) 
select i::int, 'orc-'||i from generate_series(1,1000000) i;

select count(*) from ext_orc_r;

select * from ext_orc_r order by i limit 10;

select * from ext_orc_r where i in (9,99,999);
