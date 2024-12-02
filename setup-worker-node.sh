#!/usr/bin/env bash

# Install kubeadm

sudo apt -y install containerd iptables apt-transport-https gnupg2 curl ca-certificates net-tools
sudo tee /etc/sysctl.d/99-k8s-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

sudo sysctl --system
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# # select /usr/sbin/iptables-legacy
# sudo update-alternatives --config iptables

sudo mkdir -p -m 755 /etc/apt/keyrings ||:
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

# disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo sed -i 's/^/# /g'                  /etc/initramfs-tools/conf.d/resume
# sudo fdisk /dev/sda
# d
# 3
# w

sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0"/g' /etc/default/grub
sudo update-grub
sudo ln -s /opt/cni/bin /usr/lib/cni
sudo reboot -h now

# Run kubeadm
sudo kubeadm join REDACTED:6443 --token REDACTED \
  --discovery-token-ca-cert-hash REDACTED

# Reinstall Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
