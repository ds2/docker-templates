# Payara JNDI image

To autoconfigure a payara server on boot to directly deploy JNDI WARs.

## How to build

    docker build -t payarajndi:latest .

## How to test

    docker run -it --rm -p 4848:4848 -p 8080:8080 -e JNDI_1_ID=testPool -e JNDI_1_DSCLASS=org.postgresql.ds.PGConnectionPoolDataSource -e JNDI_1_JNDI=jdbc/test1 -e JNDI_1_USER=myusr -e JNDI_1_PW=mypw -e JNDI_1_DBNAME=mydb payarajndi:latest
