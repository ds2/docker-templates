# Terraform client image

[![Docker Repository on Quay](https://quay.io/repository/ds2/terraform/status "Docker Repository on Quay")](https://quay.io/repository/ds2/terraform)

This image contains the terraform clients for v0.12, v0.13 and v0.14, as well as:

* awscli
* gcloud
* azure cli

to allow running in CI environments.

## Build image

    docker build -t terraform-cli:latest .

## Test image

    docker run -it --rm terraform-cli:latest
