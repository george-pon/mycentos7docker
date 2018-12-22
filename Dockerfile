FROM centos:centos7

ENV MYCENTOS7DOCKER_VERSION build-target
ENV MYCENTOS7DOCKER_VERSION latest
ENV MYCENTOS7DOCKER_VERSION stable
ENV MYCENTOS7DOCKER_IMAGE mycentos7docker

# see also
# https://qiita.com/0ashina0/items/f8b960e822a40a6a2eed Window10に日本語対応CentOS7のdockerコンテナを作ってみた - Qiita

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

# install kubectl CLI
RUN echo "" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "[kubernetes]" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "name=Kubernetes" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "repo_gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo && \
    echo "gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" >> /etc/yum.repos.d/kubernetes.repo
RUN yes | yum search kubectl --showduplicates
RUN yum install -y kubectl-1.11.4-0 && yum clean all

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ADD bashrc /root/.bashrc
ENV HOME /root
ENV ENV $HOME/.bashrc

CMD ["/usr/local/bin/docker-entrypoint.sh"]

