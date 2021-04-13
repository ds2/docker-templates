# Postgresql Liquibase image

An image to directly setup your database(s) by using Liquibase Database VCS.

## How to build

Run:

    docker build -t lqdb:latest .

## How to test

Run:

    docker run -it --rm -v $(pwd)/test/lqdata:/db-data:ro -v $(pwd)/test/pgconf:/pg-confs:ro -v $(pwd)/test/sql:/docker-entrypoint-initdb.d -e POSTGRES_PASSWORD=mysecretpw1 lqdb:latest
