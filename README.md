# mycentos7docker

This image is convinient environment on CentOS 7
includes man pages, iproute, bind-utils, jq, kubectl CLI.

### how to use

example 1 : run via Docker

```
function docker-run-mycentos7docker() {
    docker run -i -t --rm \
        -e http_proxy=${http_proxy} -e https_proxy=${https_proxy} -e no_proxy="${no_proxy}" \
        georgesan/mycentos7docker:stable
}
docker-run-mycentos7docker
```

example 2 : run via Kubernetes

```
function kube-run-mycentos7docker() {
    tmp_no_proxy=$( echo $no_proxy | sed -e 's/,/\,/g' )
    kubectl run mycentos7docker -i --tty --image=georgesan/mycentos7docker:stable --rm \
        --env="http_proxy=${http_proxy}" --env="https_proxy=${https_proxy}" --env="no_proxy=${tmp_no_proxy}"
}
kube-run-mycentos7docker
```
