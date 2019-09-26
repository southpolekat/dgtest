
DROP EXTERNAL TABLE IF EXISTS ext_a_w;
DROP EXTERNAL TABLE IF EXISTS ext_a_r;
DROP EXTERNAL TABLE IF EXISTS ext_b_w;
DROP EXTERNAL TABLE IF EXISTS ext_b_r;

CREATE WRITABLE EXTERNAL TABLE ext_a_w 
(
    i int,
	t text 
)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_orc/a_#SEGID#.orc') 
FORMAT 'spq';

CREATE WRITABLE EXTERNAL TABLE ext_b_w
(
    i int,
    t text
)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_orc/b_#SEGID#.orc')
FORMAT 'spq';

CREATE EXTERNAL TABLE ext_a_r 
(
    i int,
   	t text 
)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_orc/a_*.orc') 
FORMAT 'spq';

CREATE EXTERNAL TABLE ext_b_r
(
    i int,
    t text
)
LOCATION ('xdrive://127.0.0.1:7171/hdfs3_orc/b_*.orc')
FORMAT 'spq';

\timing 

insert into ext_a_w (i,t) select i::int, 'a-'||i from generate_series(1,1000000) i;
insert into ext_b_w (i,t) select i::int, 'b-'||i from generate_series(1,1000000) i;

select * from ext_a_r limit 5;
select * from ext_b_r limit 5;

select * from ext_a_r a, ext_b_r b where a.i = b.i order by a.i limit 10;
