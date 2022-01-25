#!/bin/bash
#
# kubectl logs の改良版。Pod名は一部一致していれば認める
#

function f-kubectl-logs-regex() {

    # 変数定義
    options=""
    pod_name_pattern=""

    # 引数解析
    while true
    do
        if [ $# -eq 0 ] ; then
            break
        fi
        if [ x"$1"x = x"-f"x ] ; then
            options="$options $1"
            shift
            continue
        else
            pod_name_pattern=$1
            shift
            continue
        fi
    done
    
    # 引数チェック
    if [ -z "$pod_name_pattern" ] ; then
        echo "pod name pattern is null. abort."
        return 1
    fi

    # Pod名取得
    pod_name_list=$( kubectl get pod -A | grep $pod_name_pattern | awk '{print $2}' )
    pod_namespace_list=$( kubectl get pod -A | grep $pod_name_pattern | awk '{print $1}' )

    # bash配列の宣言
    declare -a pod_name_array=( $pod_name_list )
    declare -a pod_namespace_array=( $pod_namespace_list )

    # kubectl logs 実施
    i=0
    while [ $i -lt ${#pod_name_array[*]} ]
    do
        pod_name=${pod_name_array[$i]}
        pod_namespace=${pod_namespace_array[$i]}

        # まずはdescribe
        echo ""
        echo ""
        echo ""
        echo "---------------------------------------------------------------------------------"
        echo "### kubectl describe pod --namespace $pod_namespace $pod_name"
        kubectl describe pod --namespace $pod_namespace $pod_name

        # pod の中にいる初期化コンテナ名一覧を取得
        init_container_name_list=$( kubectl get pod --namespace $pod_namespace $pod_name -o jsonpath='{range .spec.initContainers[*]}{@.name}{" "}{end}' )

        # pod の中にいるコンテナ名一覧を取得
        container_name_list=$( kubectl get pod --namespace $pod_namespace $pod_name -o jsonpath='{range .spec.containers[*]}{@.name}{" "}{end}' )

        for container_name in $init_container_name_list $container_name_list
        do
            echo ""
            echo ""
            echo ""
            echo "---------------------------------------------------------------------------------"
            echo "### kubectl logs $options --namespace $pod_namespace $pod_name -c $container_name"
            echo ""
            kubectl logs $options --namespace $pod_namespace $pod_name -c $container_name
        done

        # 次のpod
        i=$(( i + 1 ))
    done
}

f-kubectl-logs-regex "$@"

