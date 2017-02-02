#!/bin/bash

#
# System
#

rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
yum install -y facter unzip wget git bind-utils dbus-x11 epel-release
yum install python2-pip python-httplib2; pip install docker-py

#
# Rancher
#

wget -O /tmp/rancher.tar.gz https://github.com/rancher/cli/releases/download/v0.4.0/rancher-linux-amd64-v0.4.0.tar.gz
wget -O /tmp/rancher-compose.tar.gz https://github.com/rancher/rancher-compose/releases/download/v0.12.0/rancher-compose-linux-amd64-v0.12.0.tar.gz

cd /tmp; tar -xzf /tmp/rancher.tar.gz
cd /tmp; tar -xzf /tmp/rancher-compose.tar.gz

cp /tmp/rancher-compose-v0.12.0/rancher-compose /usr/bin/rancher-compose; chmod 755 /usr/bin/rancher-compose
cp /tmp/rancher-v0.4.0/rancher /usr/bin/rancher; chmod 755 /usr/bin/rancher

#
# Prepare docker
#

cat <<EOF > /etc/yum.repos.d/docker.repo
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum install docker-engine -y

mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF > /etc/systemd/system/docker.service.d/init.conf
[Service]
EnvironmentFile=-/etc/sysconfig/docker
EnvironmentFile=-/etc/sysconfig/docker-storage
EnvironmentFile=-/etc/sysconfig/docker-network
EnvironmentFile=-/etc/sysconfig/docker-registry
ExecStart=
ExecStart=/usr/bin/dockerd \$OPTIONS \$DOCKER_STORAGE_OPTIONS \$DOCKER_NETWORK_OPTIONS \$BLOCK_REGISTRY \$INSECURE_REGISTRY
EOF

cat <<EOF > /etc/sysconfig/docker-network
DOCKER_NETWORK_OPTIONS="-H tcp://127.0.0.1:2375 -H unix:///var/run/docker.sock"
EOF

cat <<EOF > /etc/sysconfig/docker-storage
DOCKER_STORAGE_OPTIONS=" --storage-driver=overlay"
EOF

systemctl daemon-reload
systemctl enable docker.service
systemctl restart docker
