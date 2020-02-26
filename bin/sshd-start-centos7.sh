#!/bin/bash
#
#  centos7 イメージ上で、sshdを開始する
#

set -e

touch /etc/rc.d/init.d/functions

echo "create host's key"
bash -x /usr/sbin/sshd-keygen

echo "start sshd daemon"
/usr/sbin/sshd -D &

echo "create users key pair."
ssh-keygen -t rsa -m PEM -N "" -f ~/.ssh/id_rsa

echo "set authorized_keys"
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

echo "SUCCESS."
