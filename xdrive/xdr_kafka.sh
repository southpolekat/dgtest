#!/bin/bash

source ../dgtest_env.sh

kafka_conf=/tmp/dgkafka.toml
kafka_host=my_kafka
kafka_port=9092
kafka_topic=testtopic
kafka_partition_num=2

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

        [[kafka.input.columns]]
        name = "i"
        type = "int"

        [[kafka.input.columns]]
        name = "a"
        type = "text"

        [[kafka.input.columns]]
        name = "t"
        type = "timestamp"

    [kafka.output]
    offset_table = "${kafka_topic}_kafka_offset_summary"
    output_table = "${db_table}"

    [kafka.commit]
    max_row = 10000
    minimal_interval = -1
EOF


cat <<EOF > ${xdrive_conf} 
[xdrive]
dir = "/tmp/xdrive"
port = ${xdrive_port} 
host = ["$sdw1", "$sdw2"]

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
psql -d ${db_name} << EOF
\set ON_ERROR_STOP true
INSERT INTO ${kafka_topic}_kafka_write SELECT i::int, i::text, now() from generate_series(1,$max) i;
EOF

dglog Read data from kafka : dgkafa load
${GPHOME}/plugin/dgkafka/dgkafka load -force-reset-earliest -quit-at-eof ${kafka_conf}
psql -d ${db_name} << EOF
SELECT * from ${db_table};
EOF

dglog dgkafa check
${GPHOME}/plugin/dgkafka/dgkafka check ${kafka_conf}
