# Frontend Builder

A container image to build frontend webapps.

## How to build

    podman build -t febuilder:latest .

## How to test

    podman run -it --rm -v $(pwd):/src febuilder:latest
