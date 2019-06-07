#!/bin/bash
#
# test run image
#
function docker-run-mycentos7docker() {
    docker pull georgesan/mycentos7docker:latest
    ${WINPTY_CMD} docker run -i -t --rm \
        -e http_proxy=${http_proxy} -e https_proxy=${https_proxy} -e no_proxy="${no_proxy}" \
        georgesan/mycentos7docker:latest
}
docker-run-mycentos7docker
