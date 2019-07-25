#!/bin/bash

db=dgtest$$
topic=customer$$
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
    format = "csv"
    delimiter = "|"
    consumer_group = "dggrp"
    topic = "$topic"
    partition_num = 3
    nwriter = 2

    ext_read_table = "customer_kafka_read"
    ext_write_table = "customer_kafka_write"
    ext_offset_table = "kafka_offset"

        [[kafka.input.columns]]
        name = "c_custkey"
        type = "integer"

        [[kafka.input.columns]]
        name = "c_name"
        type = "varchar(25)"

    [kafka.output]
    offset_table = "kafka_offset_summary"
    output_table = "customer"

    [kafka.commit]
    max_row = 10000
    minimal_interval = -1
END

echo "---------- create customer.ddl"
cat <<END > customer.ddl
DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
    C_CUSTKEY   INTEGER ,
    C_NAME      VARCHAR(25)
) distributed by (C_CUSTKEY);
END

echo "---------- create customer.csv"
cat <<END > customer.csv
1|Customer A
2|Customer B
3|Customer C
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
~/deepgreendb/plugin/csv2kafka/csv2kafka  -d '|'  -w '|' $kafka_host:9092 $topic customer.csv

echo "---------- createdb $db"
createdb $db 

echo "---------- dgkafka setup"
~/deepgreendb/plugin/dgkafka/dgkafka setup dgkafka.toml

psql -d $db -f customer.ddl

echo "---------- dgkafka load"
~/deepgreendb/plugin/dgkafka/dgkafka load -quit-at-eof dgkafka.toml

psql -d $db -c "select * from customer;"

dropdb $db 

/usr/local/kafka/bin/kafka-topics.sh --delete --bootstrap-server $kafka_host:9092 --topic $topic
