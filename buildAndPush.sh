#!/usr/bin/env bash

function buildImage(){
    local dkrPath=$1
    local tagName=$2
    local tagVersion=${3:-latest}
    echo "Building image from $dkrPath with tagName $tagName and version $tagVersion.."
    docker build --rm -f "$dkrPath/Dockerfile" -t "$tagName:$tagVersion" "$dkrPath"
}

function pushImage(){
    local tagName=$1
    local tagVersion=${2:-latest}
    echo "Pushing image $tagName with version $tagVersion to Docker Hub.."
    docker push "$tagName:$tagVersion"
}

function runTempImage(){
    local tagName=$1
    local tagVersion=${2:-latest}
    echo "Testing image.."
    local imgExec="docker run --rm -it $tagName:$tagVersion /bin/bash"
    echo "Run: $imgExec"
}

buildImage "cicd/jkslave" "dstrauss/jk-jnlp-slave" "3.29-1"
# pushImage "dstrauss/jk-jnlp-slave" "3.29-1"
runTempImage "dstrauss/jk-jnlp-slave" "3.29-1"
