# Payara JNDI image

To autoconfigure a payara server on boot to directly deploy JNDI WARs.

## How to build

    docker build -t payarajndi:latest -f Dockerfile.web .
    # docker build -t payarajndi:latest -f Dockerfile.full .

## How to test

    #docker run -it --rm -p 4848:4848 -p 8080:8080 -e JNDI_1_ID=testPool -e JNDI_1_DSCLASS=org.postgresql.ds.PGConnectionPoolDataSource -e JNDI_1_JNDI=jdbc/test1 -e JNDI_1_USER=myusr -e JNDI_1_PW=mypw -e JNDI_1_DBNAME=mydb payarajndi:latest
    docker run -it --rm -p 4848:4848 -p 8080:8080 -e JNDI_1_ID=testPool -e JNDI_1_DSCLASS=org.h2.jdbcx.JdbcDataSource -e JNDI_1_JNDI=jdbc/test1 -e JNDI_1_USER=sa -e JNDI_1_PW=123 -e JNDI_1_MINSIZE=1 -e JNDI_1_URL=jdbc:h2:file:/tmp/test\;USER=sa\;PASSWORD=123 payarajndi:latest
