#!/bin/bash

db=dgtest$$
topic=customer$$
table=customer$$
kafka_host=localhost

echo "---------- create dgkafka.toml"
cat <<END > dgkafka.toml
[dgkafka]
database = "$db"
user = "gpadmin"
password = ""
host = "localhost"
port = 5432
sslmode = "disable"
xdrive_host = "localhost"
xdrive_port = 7171 
xdrive_offset_endpoint = "kafkaoffset"
xdrive_kafka_endpoint = "kafka"
[kafka]
    [kafka.input]
    format = "json"
    consumer_group = "dggrp"
    topic = "$topic"
    partition_num = 3
    nwriter = 2

    ext_read_table = "${table}_kafka_read"
    ext_write_table = "${table}_kafka_write"
    ext_offset_table = "${table}_kafka_offset"

        [[kafka.input.columns]]
        name = "jdata"
        type = "json"

    [kafka.output]
    offset_table = "kafka_offset_summary"
    output_table = "$table"

      [[kafka.output.mappings]]
      name = "c_custkey"
      key = "(jdata->>'c_custkey')::integer"

      [[kafka.output.mappings]]
      name = "c_name"
      key = "(jdata->>'c_name')::varchar(25)"

    [kafka.commit]
    max_row = 10000
    minimal_interval = -1
END

echo "---------- create $table.ddl"
cat <<END > $table.ddl
DROP TABLE IF EXISTS $table;
CREATE TABLE $table (
    C_CUSTKEY   INTEGER ,
    C_NAME      VARCHAR(25)
) distributed by (C_CUSTKEY);
END

echo "---------- create $table.json"
cat <<END > $table.json
{ "c_custkey" : "1", "c_name" : "Customer A" }
{ "c_custkey" : "2", "c_name" : "Customer B" }
{ "c_custkey" : "3", "c_name" : "Customer C" }
END

echo "---------- create xdrive.toml"
cat <<END > xdrive.toml
[xdrive]
dir = "/home/gpadmin/xdrive"
port = 7171
host = ["localhost"]

[[xdrive.mount]]
name = "kafka"
argv = ["xdr_kafka/xdr_kafka", "$kafka_host:9092"]

[[xdrive.mount]]
name = "kafkaoffset"
argv = ["xdr_kafkaoffset/xdr_kafkaoffset", "$kafka_host:9092"]
END

echo "---------- restart xdrive"
xdrctl stop xdrive.toml
xdrctl deploy xdrive.toml
xdrctl start xdrive.toml

echo "---------- create topic $topic in kafka"
/usr/local/kafka/bin/kafka-topics.sh --create --zookeeper $kafka_host:2181 --replication-factor 1 --partitions 3 --topic $topic 

echo "---------- load data to kafka"
cat $table.json | /usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic $topic 

echo "---------- createdb $db"
createdb $db 

echo "---------- dgkafka setup"
~/deepgreendb/plugin/dgkafka/dgkafka setup dgkafka.toml

psql -d $db -f $table.ddl

echo "---------- dgkafka load"
~/deepgreendb/plugin/dgkafka/dgkafka load -quit-at-eof dgkafka.toml

psql -d $db -c "select * from $table;"

dropdb $db 

/usr/local/kafka/bin/kafka-topics.sh --delete --bootstrap-server $kafka_host:9092 --topic $topic

rm -rf $table.json $table.ddl dgkafka.toml xdrive.toml
