# Nginx for SSO

Credit to <https://github.com/zmartzone/lua-resty-openidc>.

## How to build

The configuration is kind of done using the oic.lua file. Then it gets
copied into the nginx.conf file into the access_lua_block.

Now you can build the image:

    docker build -t nginx-sso:latest .

## How to test

    docker run -it --rm -p 8081:8080 -e OIDC_CLIENTID=myClientId -e OIDC_CLIENTSECRET=myClientSecret nginx-sso:latest

Open <http://localhost:8081/> now.
