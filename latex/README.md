# LaTeX image

To run latex from a container.

## How to build

    docker build --rm --pull -t latex:latest .

## How to test

    docker run -it --rm -v $(pwd):/workspace latex:latest id
    docker run -it --rm -v $(pwd):/workspace latex:latest /bin/bash
    mkdir $(pwd)/tmp
    docker run -it --rm -v $(pwd):/workspace latex:latest latex -output-format=pdf -output-dir=./tmp test1.tex
