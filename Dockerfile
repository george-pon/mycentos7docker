FROM centos:centos7

ENV MYCENTOS7DOCKER_VERSION build-target
ENV MYCENTOS7DOCKER_VERSION latest
ENV MYCENTOS7DOCKER_VERSION stable
ENV MYCENTOS7DOCKER_IMAGE mycentos7docker


# install CentOS Project GPG public key
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

# update all packages
RUN yum -y update && yum clean all

# set locale to Japanese
RUN localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
RUN echo 'LANG="ja_JP.UTF-8"' >  /etc/locale.conf
ENV LANG ja_JP.UTF-8

# set install flag manual page
RUN sed -i -e"s/^tsflags=nodocs/\# tsflags=nodocs/" /etc/yum.conf

# install man, man-pages
RUN yum -y install man man-pages man-pages-ja && yum clean all

# install network utils
RUN yum install -y iproute net-tools bind-utils && yum clean all

# add EPEL yum repository
RUN yum install -y epel-release && yum clean all

# install jq
RUN yum install -y jq && yum clean all

# install ansible
RUN yum install -y ansible && yum clean all

# install git
RUN yum install -y git && yum clean all

# install other tools
RUN yum install -y openssh-server openssh-clients make wget sudo vim expect && yum clean all

# install docker client
ARG DOCKERURL=https://download.docker.com/linux/static/stable/x86_64/docker-18.06.1-ce.tgz
RUN curl -fSL "$DOCKERURL" -o docker.tgz \
    && tar -xzvf docker.tgz \
    && mv docker/* /usr/bin/ \
    && rmdir docker \
    && rm docker.tgz \
    && chmod +x /usr/bin/docker 

# install kubectl CLI
ENV KUBECTL_CLIENT_VERSION 1.11.4-0
RUN echo "" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "[kubernetes]" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "name=Kubernetes" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "repo_gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" >> /etc/yum.repos.d/kubernetes.repo
RUN yes | yum search kubectl --showduplicates
RUN yum install -y kubectl-${KUBECTL_CLIENT_VERSION} && yum clean all

# install helm CLI v2.9.1
ENV HELM_CLIENT_VERSION v2.9.1
RUN curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${HELM_CLIENT_VERSION}-linux-amd64.tar.gz && \
    tar xzf  helm-${HELM_CLIENT_VERSION}-linux-amd64.tar.gz && \
    /bin/cp  linux-amd64/helm   /usr/bin && \
    /bin/rm -rf rm helm-${HELM_CLIENT_VERSION}-linux-amd64.tar.gz linux-amd64

# install kompose v1.17.0
ENV KOMPOSE_VERSION v1.17.0
RUN curl -LO https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-amd64.tar.gz && \
    tar xzf kompose-linux-amd64.tar.gz && \
    chmod +x kompose-linux-amd64 && \
    mv kompose-linux-amd64 /usr/bin/kompose && \
    rm kompose-linux-amd64.tar.gz

# install stern
ENV STERN_VERSION 1.10.0
RUN curl -LO https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 && \
    chmod +x stern_linux_amd64 && \
    mv stern_linux_amd64 /usr/bin/stern

# install envsubst
RUN yum install -y gettext && yum clean all

# install kustomize
ENV KUSTOMIZE_VERSION 1.0.11
RUN curl -LO https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64 && \
    chmod +x kustomize_${KUSTOMIZE_VERSION}_linux_amd64 && \
    mv kustomize_${KUSTOMIZE_VERSION}_linux_amd64 /usr/bin/kustomize

# install yamlsort
ENV YAMLSORT_VERSION v0.1.13
RUN curl -LO https://github.com/george-pon/yamlsort/releases/download/${YAMLSORT_VERSION}/linux_amd64_yamlsort_${YAMLSORT_VERSION}.tar.gz && \
    tar xzf linux_amd64_yamlsort_${YAMLSORT_VERSION}.tar.gz && \
    chmod +x linux_amd64_yamlsort && \
    mv linux_amd64_yamlsort /usr/bin/yamlsort && \
    rm linux_amd64_yamlsort_${YAMLSORT_VERSION}.tar.gz

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ADD bashrc /root/.bashrc
ADD bash_profile /root/.bash_profile
ENV HOME /root
ENV ENV $HOME/.bashrc

CMD ["/usr/local/bin/docker-entrypoint.sh"]

