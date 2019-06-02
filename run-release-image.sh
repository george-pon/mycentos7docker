#!/bin/bash
#
# test run image
#
function docker-run-myalpine3docker() {
    docker pull georgesan/myalpine3docker:latest
    ${WINPTY_CMD} docker run -i -t --rm \
        -e http_proxy=${http_proxy} -e https_proxy=${https_proxy} -e no_proxy="${no_proxy}" \
        registry.gitlab.com/george-pon/myalpine3docker:latest
}
docker-run-myalpine3docker
