#!/usr/bin/env bash

# disable swap (k8s requirement)
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

# install kubernetes
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet=1.10.5-00 kubeadm=1.10.5-00 kubectl=1.10.5-00

# change the cgroup-driver
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
