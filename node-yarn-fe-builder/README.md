# Frontend Builder

[![Docker Repository on Quay](https://quay.io/repository/ds2/frontend-builder/status "Docker Repository on Quay")](https://quay.io/repository/ds2/frontend-builder)

A container image to build frontend webapps via NodeJs, Yarn, npx, the Angular client etc.

## How to build

    podman build -t quay.io/ds2/frontend-builder:latest .

## How to test

In your local frontend stuff directory (package.json), run:

    podman run -it --rm -v $(pwd):/src quay.io/ds2/frontend-builder:latest
