#!/bin/bash 

echo test Postgres jdbc connection
javac TestConPostgres.java
java -cp .:/home/gpadmin/postgresql-42.2.1.jar TestConPostgres

echo test mysql jdbc connection
javac TestConMysql.java
java -cp .:/usr/share/java/mysql.jar TestConMysql

echo test oracle jdbc connection
javac TestConOracle.java
java -cp .:/home/gpadmin/ojdbc8.jar TestConOracle

echo test DB2 jdbc connection
javac TestConDb2.java
java -cp .:/home/gpadmin/db2jcc-db2jcc4.jar TestConDb2

rm *.class
