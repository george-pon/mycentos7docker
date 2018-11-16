#!/bin/bash

function car() {
    echo $1
}

function cdr() {
    shift
    echo "$@"
}

function f_docker_build() {
    TAG_LIST=$(awk '/^ENV MYCENTOS7DOCKER_VERSION/ {print $3;}' Dockerfile)
    TAG_CAR=$(car $TAG_LIST)
    TAG_CDR=$(cdr $TAG_LIST)
    echo $TAG_CDR
    IMAGE_NAME=$(awk '/^ENV MYCENTOS7DOCKER_IMAGE/ {print $3;}' Dockerfile)

    if [ ! -z "$no_cache" ]; then
        BUILD_OPT="$BUILD_OPT --no-cache"
    fi

    echo docker build -t ${IMAGE_NAME}:${TAG_CAR} .
    $SUDO_DOCKER docker build $BUILD_OPT -t ${IMAGE_NAME}:${TAG_CAR} .
    RC=$?
    if [ $RC -ne 0 ]; then
        echo "ERROR: docker build failed."
        return 1
    fi

    for i in $TAG_CDR
    do
        echo docker tag ${IMAGE_NAME}:$TAG_CAR ${IMAGE_NAME}:$i
        $SUDO_DOCKER docker tag ${IMAGE_NAME}:$TAG_CAR ${IMAGE_NAME}:$i
    done

    return 0
}

f_docker_build
