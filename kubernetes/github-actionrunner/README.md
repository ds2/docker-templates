# Github ActionRunner sample

## Build it

    docker build -t delme:latest .

## Test it first

    docker run -it --rm opensuse/leap:15 /bin/bash
    docker run -it --rm delme:latest /bin/zsh

## Final Test

    docker run -it --rm -e REPOURL=https://github.com/my/repo/url -e REPOTOKEN=MYTOKEN delme:latest
