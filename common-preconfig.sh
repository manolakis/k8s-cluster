#!/usr/bin/env bash

yum update -y
yum install wget -y
systemctl disable firewalld && systemctl stop firewalld

# disable selinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# enable br_netfilter kernel module
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

# disable swapp
swapoff -a
sed -i '/swap/ s/^/#/' /etc/fstab

# adds IPs to /etc/hosts
function add_to_hosts() {
    if ! grep --quiet $1 /etc/hosts; then
        echo $1 $2 >> /etc/hosts
        echo added $1 $2 into /etc/hosts
    fi
}

add_to_hosts "10.0.15.10" master
for i in `seq 1 $1`
do
    add_to_hosts "10.0.15.$(($i + 20))" node$i
done

# install docker-ce
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

# install kubernetes
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

setenforce 0
yum install -y kubelet kubeadm kubectl
