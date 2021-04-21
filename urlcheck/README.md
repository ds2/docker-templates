# Dummy URL Checker

[![Docker Repository on Quay](https://quay.io/repository/ds2/url-checker/status "Docker Repository on Quay")](https://quay.io/repository/ds2/url-checker)

A dummy url checker written in Rust. The idea is to run this image in a kubernetes cluster as
a cronjob so that you get a urlcheck every minute etc. and you may report the errored urls
via a bash script to someone. As a sample I will provide here OpsGenie to test with.

## How to use

### Environment variables

* URL=https://www.pcwelt.de/ = instead of a CSV, try to test only this single url
* URL_TIMEOUT=10 = defines the read/connect timeout, in seconds
* ON_EACH_FAIL="/opsgenie.sh" = defines which command should be run for each failed url; the url is given as parameter
* OPSGEN_APIKEY="12345" = defines the opsgenie api key
* OPSGEN_TEAM_NAME="My Team Name" = defines the team name in OpsGenie to inform
* OPSGEN_PRIO="P1" = defines the priority of the alert, with P1 the most critical
* RUST_LOG=info = defines the log level for the logger; you may also want to use debug or trace here
* CSV_FILE=/data/urls.csv = defines where to look for the csv file with all the urls to test

## How to build

Run:

    docker build -t urlchecker:latest .

## How to Test

    docker run -it --rm -e URL=https://www.pcwelt.de/ urlchecker:latest
    docker run -it --rm -e CSV_FILE=/test/test.csv -v $(pwd):/test urlchecker:latest
