#!/usr/bin/env bash

# start services docker & kubelet
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet

# change the cgroup-driver
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
systemctl restart kubelet
