#!/bin/bash 

echo test mysql jdbc connection
javac TestConMysql.java
java -cp .:/usr/share/java/mysql.jar TestConMysql

echo test oracle jdbc connection
javac TestConOracle.java
java -cp .:/home/gpadmin/ojdbc8.jar TestConOracle

rm *.class
