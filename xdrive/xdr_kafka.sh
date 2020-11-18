#!/bin/bash

source ../dgtest_env.sh

format=${1:-csv} 	# csv, json 

kafka_conf=/tmp/dgkafka.toml
kafka_host=my_kafka
kafka_port=9092
kafka_partition_num=2

[ $format == "csv" ] && kafka_topic=testtopiccsv
[ $format == "json" ] && kafka_topic=testtopicjson

if [ ${format} == "csv" ];
then
   kafka_topic=testtopiccsv
   input_columns='
        [[kafka.input.columns]]
        name = "i"
        type = "int"

        [[kafka.input.columns]]
        name = "a"
        type = "text"

        [[kafka.input.columns]]
        name = "t"
        type = "timestamp"
   '
   output_mappings=''
fi

if [ ${format} == "json" ];
then
   kafka_topic=testtopicjson
   input_columns='
     [[kafka.input.columns]]
     name = "jdata"
     type = "json"
   '
   output_mappings="
     [[kafka.output.mappings]]
     name = 'i'
     key = \"(jdata->>'i')::int\"

     [[kafka.output.mappings]]
     name = 'a'
     key = \"(jdata->>'a')::text\"

     [[kafka.output.mappings]]
     name = 't'
     key = \"(jdata->>'t')::timestamp\"
    "
fi

dglog Create ${kafka_conf} 
cat <<EOF > ${kafka_conf} 
[dgkafka]
database = "${db_name}"
user = "${db_user}"
password = ""
host = "${db_host}"
port = ${db_port} 
sslmode = "disable"

xdrive_host = "localhost"
xdrive_port = ${xdrive_port} 
xdrive_offset_endpoint = "kafkaoffset"
xdrive_kafka_endpoint = "kafka"

[kafka]
   [kafka.input]
   format = "csv"
   delimiter = "|"
   consumer_group = "dggrp"
   topic = "${kafka_topic}"
   partition_num = ${kafka_partition_num}
   nwriter = 2

   ext_read_table = "${kafka_topic}_kafka_read"
   ext_write_table = "${kafka_topic}_kafka_write"
   ext_offset_table = "${kafka_topic}_kafka_offset"

   ${input_columns}

   [kafka.output]
   offset_table = "${kafka_topic}_kafka_offset_summary"
   output_table = "${db_table}"

   ${output_mappings}

   [kafka.commit]
   max_row = 10000
   minimal_interval = -1
EOF

cat ${kafka_conf}

dglog Create ${xdrive_conf} 
cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = ${xdrive_port} 
host = ${xdrive_host}

[[xdrive.mount]]
name = "kafka"
argv = ["xdr_kafka/xdr_kafka", "${kafka_host}:${kafka_port}"]

[[xdrive.mount]]
name = "kafkaoffset"
argv = ["xdr_kafkaoffset/xdr_kafkaoffset", "${kafka_host}:${kafka_port}"]
EOF

dglog xdrive stop, deploy and start
xdrctl stop ${xdrive_conf}
xdrctl deploy ${xdrive_conf}
xdrctl start ${xdrive_conf}
dglog pid of xdrive
gpssh -f ${hostfile} pidof xdrive

psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
drop table if exists ${db_table}; 
CREATE TABLE ${db_table} (
        i int,
        a text,
        t timestamp
) distributed randomly;
EOF

dglog dgkafka setup
${GPHOME}/plugin/dgkafka/dgkafka setup ${kafka_conf}

dglog Insert data to kafka
max=10
if [ ${format} == "csv" ]; then
psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
INSERT INTO ${kafka_topic}_kafka_write SELECT i::int, i::text, now() from generate_series(1,$max) i;
EOF
fi

if [ ${format} == "json" ]; then
psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
INSERT INTO ${kafka_topic}_kafka_write values ('{"i":1, "a":"a", "t":"2020-01-01 01:01:01"}');
INSERT INTO ${kafka_topic}_kafka_write values ('{"i":2, "a":"b", "t":"2020-02-02 02:02:02"}');
EOF
fi

dglog Read data from kafka : dgkafa load
${GPHOME}/plugin/dgkafka/dgkafka load -quit-at-eof ${kafka_conf}
psql -d ${db_name} << EOF
SELECT * from ${db_table};
EOF

dglog dgkafa check
${GPHOME}/plugin/dgkafka/dgkafka check ${kafka_conf}
