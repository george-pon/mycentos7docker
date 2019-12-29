FROM centos:centos7

ENV MYCENTOS7DOCKER_VERSION build-target
ENV MYCENTOS7DOCKER_VERSION latest
ENV MYCENTOS7DOCKER_VERSION stable
ENV MYCENTOS7DOCKER_IMAGE mycentos7docker


# install CentOS Project GPG public key
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

# set install flag manual page
RUN sed -i -e"s/^tsflags=nodocs/\# tsflags=nodocs/" /etc/yum.conf

# update all packages
RUN yum -y update && yum clean all

# set locale to Japanese
RUN localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
RUN echo 'LANG="ja_JP.UTF-8"' >  /etc/locale.conf
ENV LANG ja_JP.UTF-8

# install man, man-pages
RUN yum -y install man man-pages man-pages-ja && yum clean all

# add EPEL yum repository
RUN yum install -y epel-release && yum clean all

# install tools
RUN yum install -y \
        ansible \
        bash-completion \
        bind-utils \
        connect \
        connect-proxy \
        curl \
        emacs-nox \
        expect \
        gettext \
        git \
        iproute \
        jq \
        lsof \
        make \
        mongodb \
        net-tools \
        nmap-ncat \
        openssh-clients \
        openssh-server \
        postgresql \
        python-pip \
        stress \
        sudo \
        tcpdump \
        traceroute \
        tree \
        unzip \
        vim \
        w3m \
        wget \
        zip \
    && yum clean all

# upgrade pip
RUN pip install --upgrade pip

# install azure cli command
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    echo "[azure-cli]"    > /etc/yum.repos.d/azure-cli.repo  && \
    echo "name=Azure CLI" >> /etc/yum.repos.d/azure-cli.repo  && \
    echo "baseurl=https://packages.microsoft.com/yumrepos/azure-cli" >> /etc/yum.repos.d/azure-cli.repo  && \
    echo "enabled=1" >> /etc/yum.repos.d/azure-cli.repo  && \
    echo "gpgcheck=1" >> /etc/yum.repos.d/azure-cli.repo  && \
    echo "gpgkey=https://packages.microsoft.com/keys/microsoft.asc" >> /etc/yum.repos.d/azure-cli.repo  && \
    yum install -y azure-cli  && yum clean all

# install docker client
ARG DOCKERURL=https://download.docker.com/linux/static/stable/x86_64/docker-18.06.1-ce.tgz
RUN curl -fSL "$DOCKERURL" -o docker.tgz \
    && tar -xzvf docker.tgz \
    && mv docker/* /usr/bin/ \
    && rmdir docker \
    && rm docker.tgz \
    && chmod +x /usr/bin/docker 

# install kubectl CLI
RUN echo "" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "[kubernetes]" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "name=Kubernetes" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "repo_gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" >> /etc/yum.repos.d/kubernetes.repo
# RUN yes | yum search kubectl --showduplicates
# RUN yum install -y kubectl-${KUBECTL_CLIENT_VERSION} && yum clean all
RUN yum install -y kubectl && yum clean all

# install helm CLI v2.9.1
ENV HELM_CLIENT_VERSION v2.9.1
RUN curl -fLO https://storage.googleapis.com/kubernetes-helm/helm-${HELM_CLIENT_VERSION}-linux-amd64.tar.gz && \
    tar xzf  helm-${HELM_CLIENT_VERSION}-linux-amd64.tar.gz && \
    /bin/cp  linux-amd64/helm   /usr/bin && \
    /bin/rm -rf rm helm-${HELM_CLIENT_VERSION}-linux-amd64.tar.gz linux-amd64

# install kompose v1.18.0
ENV KOMPOSE_VERSION v1.18.0
RUN curl -fLO https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-amd64.tar.gz && \
    tar xzf kompose-linux-amd64.tar.gz && \
    chmod +x kompose-linux-amd64 && \
    mv kompose-linux-amd64 /usr/bin/kompose && \
    rm kompose-linux-amd64.tar.gz

# install stern
ENV STERN_VERSION 1.10.0
RUN curl -fLO https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 && \
    chmod +x stern_linux_amd64 && \
    mv stern_linux_amd64 /usr/bin/stern

# install kustomize
ENV KUSTOMIZE_VERSION 1.0.11
RUN curl -fLO https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64 && \
    chmod +x kustomize_${KUSTOMIZE_VERSION}_linux_amd64 && \
    mv kustomize_${KUSTOMIZE_VERSION}_linux_amd64 /usr/bin/kustomize

# install kubectx, kubens. see https://github.com/ahmetb/kubectx
RUN curl -fLO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && \
    curl -fLO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens && \
    chmod +x kubectx kubens && \
    mv kubectx kubens /usr/local/bin

# install kubeval ( validate Kubernetes yaml file to Kube-API )
ENV KUBEVAL_VERSION 0.7.3
RUN curl -fLO https://github.com/garethr/kubeval/releases/download/$KUBEVAL_VERSION/kubeval-linux-amd64.tar.gz && \
    tar xf kubeval-linux-amd64.tar.gz && \
    cp kubeval /usr/local/bin && \
    /bin/rm kubeval-linux-amd64.tar.gz

# install kubetest ( lint kubernetes yaml file )
ENV KUBETEST_VERSION 0.1.1
RUN curl -fLO https://github.com/garethr/kubetest/releases/download/$KUBETEST_VERSION/kubetest-linux-amd64.tar.gz && \
    tar xf kubetest-linux-amd64.tar.gz && \
    cp kubetest /usr/local/bin && \
    /bin/rm kubetest-linux-amd64.tar.gz

# install yamlsort
ENV YAMLSORT_VERSION v0.1.16
RUN curl -fLO https://github.com/george-pon/yamlsort/releases/download/${YAMLSORT_VERSION}/linux_amd64_yamlsort_${YAMLSORT_VERSION}.tar.gz && \
    tar xzf linux_amd64_yamlsort_${YAMLSORT_VERSION}.tar.gz && \
    chmod +x linux_amd64_yamlsort && \
    mv linux_amd64_yamlsort /usr/bin/yamlsort && \
    rm linux_amd64_yamlsort_${YAMLSORT_VERSION}.tar.gz

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ADD bashrc /root/.bashrc
ADD bash_profile /root/.bash_profile
ADD emacsrc /root/.emacs
ADD vimrc /root/.vimrc
ADD bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh

ENV HOME /root
ENV ENV $HOME/.bashrc

# add sudo user
# https://qiita.com/iganari/items/1d590e358a029a1776d6 Dockerコンテナ内にsudoユーザを追加する - Qiita
# ユーザー名 centos
# パスワード hogehoge
RUN groupadd -g 1000 centos && \
    useradd  -g      centos -G wheel -m -s /bin/bash centos && \
    echo 'centos:hogehoge' | chpasswd && \
    echo 'Defaults visiblepw'            >> /etc/sudoers && \
    echo 'centos ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# use normal user centos
# USER centos

CMD ["/usr/local/bin/docker-entrypoint.sh"]

