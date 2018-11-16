# mycentos7docker

My CentOS7 docker image for convinient.

This image includes man pages, iproute, bind-utils, jq, kubectl.

### how to use

from Docker
```
function docker-run-mycentos7docker() {
    docker run -i -t --rm \
        -e http_proxy=${http_proxy} -e https_proxy=${https_proxy} -e no_proxy="${no_proxy}" \
        georgesan/mycentos7docker:stable
}
docker-run-mycentos7docker
```

from Kubernetes
```
function kube-run-mycentos7docker() {
    tmp_no_proxy=$( echo $no_proxy | sed -e 's/,/\,/g' )
    kubectl run mycentos7docker -i --tty --image=georgesan/mycentos7docker:stable --rm \
        --env="http_proxy=${http_proxy}" --env="https_proxy=${https_proxy}" --env="no_proxy=${tmp_no_proxy}"
}
kube-run-mycentos7docker
```
