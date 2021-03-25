# Payara JNDI image

[![Docker Repository on Quay](https://quay.io/repository/ds2/jeeserver-full/status "Docker Repository on Quay")](https://quay.io/repository/ds2/jeeserver-full)
[![Docker Repository on Quay](https://quay.io/repository/ds2/jeeserver-web/status "Docker Repository on Quay")](https://quay.io/repository/ds2/jeeserver-web)

To autoconfigure a payara server on boot to directly deploy JNDI configs.

## How to build

    docker build -t payarajndi:latest -f Dockerfile.web .
    # docker build -t payarajndi:latest -f Dockerfile.full .

## How to test

    #docker run -it --rm -p 4848:4848 -p 8080:8080 -e JNDI_1_ID=testPool -e JNDI_1_DSCLASS=org.postgresql.ds.PGConnectionPoolDataSource -e JNDI_1_JNDI=jdbc/test1 -e JNDI_1_USER=myusr -e JNDI_1_PW=mypw -e JNDI_1_DBNAME=mydb payarajndi:latest
    docker run -it --rm -p 4848:4848 -p 8080:8080 -e JNDI_1_ID=testPool -e JNDI_1_DSCLASS=org.h2.jdbcx.JdbcDataSource -e JNDI_1_JNDI=jdbc/test1 -e JNDI_1_USER=sa -e JNDI_1_PW=123 -e JNDI_1_MINSIZE=1 -e JNDI_1_URL=jdbc:h2:file:/tmp/test\;USER=sa\;PASSWORD=123 payarajndi:latest
    docker run -it --rm -p 4848:4848 -p 8080:8080 -e JNDI_1_ID=testPool -e JNDI_1_DSCLASS=org.h2.jdbcx.JdbcDataSource -e JNDI_1_JNDI=jdbc/test1 -e JNDI_1_USER=sa -e JNDI_1_PW=123 -e JNDI_1_MINSIZE=1 -e "JNDI_1_URL=jdbc:h2:mem:testdb\;USER=sa\;PASSWORD=123\;INIT=create schema if not exists test" payarajndi:latest

Login to <https://localhost:4848/> and use admin:admin as credentials. Check the JDBC Connection pools.
