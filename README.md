# mycentos7docker

This image is my convinient environment on CentOS 7
includes man pages, iproute, bind-utils, jq, kubectl CLI.

## how to use

### run via Docker

```
function docker-run-mycentos7docker() {
    ${WINPTY_CMD} docker run -i -t --rm \
        -e http_proxy=${http_proxy} -e https_proxy=${https_proxy} -e no_proxy="${no_proxy}" \
        georgesan/mycentos7docker:stable
}
docker-run-mycentos7docker
```

### run via Kubernetes

```
function kube-run-mycentos7docker() {
    local tmp_no_proxy=$( echo $no_proxy | sed -e 's/,/\,/g' )
    ${WINPTY_CMD} kubectl run mycentos7docker -i --tty --image=georgesan/mycentos7docker:stable --rm \
        --env="http_proxy=${http_proxy}" --env="https_proxy=${https_proxy}" --env="no_proxy=${tmp_no_proxy}"
}
kube-run-mycentos7docker
```

### run via Kubernetes with service account

This pod runs with service account mycentos7docker that has ClusterRoleBindings cluster-admin.

```
function kube-run-mycentos7docker() {
    local namespace=
    local tmp_no_proxy=$( echo $no_proxy | sed -e 's/,/\,/g' )
    while [ $# -gt 0 ]
    do
        if [ x"$1"x = x"-n"x -o x"$1"x = x"--namespace"x ]; then
            namespace=$2
            shift
            shift
            continue
        fi
        shift
    done
    if [ -z "$namespace" ]; then
        namespace=default
    fi

    kubectl -n ${namespace} create serviceaccount mycentos7docker

    kubectl create clusterrolebinding mycentos7docker \
        --clusterrole cluster-admin \
        --serviceaccount=${namespace}:mycentos7docker

    ${WINPTY_CMD} kubectl run mycentos7docker -i --tty --image=georgesan/mycentos7docker:stable --rm \
        --serviceaccount=mycentos7docker \
        --namespace=${namespace} \
        --env="http_proxy=${http_proxy}" --env="https_proxy=${https_proxy}" --env="no_proxy=${tmp_no_proxy}"
}

kube-run-mycentos7docker -n default
```


### tips run kubectl in kubernetes pod

```
kubectl proxy &
kubectl get cluster-info
kubectl get pod,svc
```



### other tips winpty ( Git-Bash for Windows )(MSYS2)

the environment variable WINPTY_CMD is set by below.

```
# set WINPTY_CMD environment variable when it need.
function check_winpty() {
    if type tty.exe ; then
        if type winpty.exe ; then
            local ttycheck=$( tty | grep "/dev/pty" )
            if [ ! -z "$ttycheck" ]; then
                export WINPTY_CMD=winpty
                echo "winpty"
                return 0
            else
                export WINPTY_CMD=
                echo ""
                return 0
            fi
        fi
    fi
    return 0
}
check_winpty

```

### how to build

```
bash build-image.sh
```




