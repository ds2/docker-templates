#!/usr/bin/env bash

GITHASH=$(git rev-parse --short=10 HEAD)

PUSH=0
DIRECTORY=""
REPO="delme"
TAGS=""
BUILD_ARGS=""

while getopts ':pd:b:r:t:b:' OPTION; do
    case "$OPTION" in
    p) PUSH=1 ;;
    d) DIRECTORY="$OPTARG" ;;
    r) REPO="$OPTARG" ;;
    t) TAGS="$OPTARG" ;;
    b) BUILD_ARGS="$OPTARG" ;;
    \?) echo "Invalid param: $OPTARG" ;;
    *)
        echo "Unbekannter Parameter"
        echo "Usage:"
        echo "$0"
        echo "  -d DIRECTORY = defines the directory to look for the Containerfile"
        echo "  -r REPO = sets the registry and repository to use; i.e. quay.io/org/image"
        echo "  -p = push to REPO"
        echo "  -b ""a=1 b=2"" = defines some build args"
        echo "As tags, we use the git short checksum, and LATEST."
        ;;
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
    for t in $TAGS; do
        echo "Pushing image with tag $t .."
        #podman tag ${repo}:latest ${repo}:${t} || exit 1
        podman push ${repo}:${t} || exit 2
    done
}

function buildImage() {
    local dir=$1
    local repo=$2
    echo "Building image $repo.."
    CMD="podman build --label local.githash=$GITHASH --label built.by=$(whoami) --no-cache --squash-all -t ""${repo}:latest"" "
    for b in $BUILD_ARGS; do
        CMD+=" --build-arg ""$b"""
    done
    CMD+=" $dir"
    echo "  will use CMD: $CMD"
    eval $CMD || exit 1
    for t in $TAGS; do
        echo "retagging latest as $t"
        podman tag $repo:latest $repo:$t || exit 3
    done
    podman image ls $repo:latest
    echo "You may run the image now via:"
    echo "  podman run -it --rm ${repo}:latest"
}

# buildImage "$DIRECTORY" "$REPO"

if [ $PUSH -eq 1 ]; then
    uploadImage "$REPO"
else
    buildImage "$DIRECTORY" "$REPO"
fi
