#!/bin/bash 

db=${1:-all}

case $db in 
	postgres | all )
		echo test Postgres jdbc connection
		javac TestConPostgres.java
		java -cp .:/home/gpadmin/postgresql-42.2.1.jar TestConPostgres
		;;
	mysql | all )
		echo test mysql jdbc connection
		javac TestConMysql.java
		java -cp .:/usr/share/java/mysql.jar TestConMysql
		;;
	oracle | all )
		echo test oracle jdbc connection
		javac TestConOracle.java
		java -cp .:/home/gpadmin/ojdbc8.jar TestConOracle
		;;
	db2 | all )
		echo test DB2 jdbc connection
		javac TestConDb2.java
		java -cp .:/home/gpadmin/db2jcc-db2jcc4.jar TestConDb2
		;;
     mssql | all )
          echo test Mssql jdbc connection
          javac TestConMssql.java
          java -cp .:/home/gpadmin/mssql-jdbc-8.4.1.jre8.jar TestConMssql
          ;;
esac

rm *.class
