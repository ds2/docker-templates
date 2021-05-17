#!/usr/bin/env bash

GITHASH=$(git rev-parse --short=10 HEAD)

PUSH=0
DIRECTORY=""
REPO="delme"

while getopts ':pd:b:r:' OPTION; do
    case "$OPTION" in
    p) PUSH=1 ;;
    d) DIRECTORY="$OPTARG" ;;
    r) REPO="$OPTARG";;
    *) echo "Unbekannter Parameter" ;;
    \?) echo "Invalid param: $OPTARG" ;;
    esac
done

if [ -z "$DIRECTORY" ]; then
    echo "Directory is missing! Use -d DIR"
    exit 1
fi
if [ -z "$REPO" ]; then
    echo "Repository is missing! Use -r REPOBASENAME"
    exit 1
fi

function uploadImage() {
    local repo="$1"
    echo "Retagging $repo from latest to $GITHASH"
    docker tag ${repo}:latest ${repo}:${GITHASH} || exit 1
    echo "Pushing image with hash first.."
    docker push ${repo}:${GITHASH} || exit 2
    echo "And now the latest tag"
    docker push ${repo}:latest || exit 3
}

function buildImage(){
    local dir=$1
    local repo=$2
    echo "Building image $repo.."
    docker build -t "${repo}:latest" $dir
    echo "You may run the image now via:"
    echo "  docker run -it --rm ${repo}:latest"
}

buildImage "$DIRECTORY" "$REPO"

if [ $PUSH -eq 1 ]; then
    uploadImage "$REPO"
fi
