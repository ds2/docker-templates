# Nginx for SSO

## How to build

    docker build -t nginx-sso:latest .

## How to test

    docker run -it --rm -p 8081:80 nginx-sso:latest