#!/bin/bash

echo "Installing container runtime..."

# Update package index and install required packages
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lolcat

# Install Docker's GPG key
sudo install -m 0755 -d /etc/apt/trusted.gpg.d/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

# Add Docker's APT repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index and install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Remove containerd's state directory and restart the service
sudo rm -rf /etc/containerd/*
sudo systemctl restart containerd

# Check Docker and containerd status
timeout 3 systemctl status docker
echo "__///////\\\\\\\__"
timeout 3 systemctl status containerd

# Disable swap for Kubernetes
sudo swapoff -a

# Load kernel modules required by Kubernetes
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Set kernel parameters required by Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Install Kubernetes packages
echo "Installing kubeadm, kubelet, and kubectl..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sleep 2
sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg ;
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg;
sleep 2


# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sleep 3

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Done!"


# Task 8
echo "----------"
kubeip=$(ip addr | grep -i eth | grep -i inet | awk '{print $2}' | cut -d "/" -f1)
sudo kubeadm init --control-plane-endpoint=${kubeip} --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/containerd/containerd.sock

# Task 9
mkdir -p $HOME/.kube
sleep 1
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sleep 1
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sleep 1

# Task 10
wget https://github.com/kubecolor/kubecolor/releases/download/v0.2.2/kubecolor_0.2.2_linux_amd64.tar.gz
tar -xzvf kubecolor_0.2.2_linux_amd64.tar.gz
mv kubecolor /usr/local/bin

echo "alias k=kubecolor" >> ~/.bashrc
source ~/.bashrc
sleep 20

# Task 11
kubectl taint nodes localhost node-role.kubernetes.io/control-plane:NoSchedule-

# Task 12
kubectl get nodes

# Task 13
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh > /dev/null
sleep 1
helm version

# Task 14
sleep 20
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sleep 20

# Task 15
cilium install --version 1.15.1
sleep 10

echo "Congrats man"
