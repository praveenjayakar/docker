#!/bin/bash

set -e

# Task 0
echo "[Task 0] Updating all the packages"
sudo apt-get update -qq -y

# Task 1
echo "[Task 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Task 2
echo "[Task 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

# Task 3
echo "[Task 3] Enable and Load Kernel modules"
cat >> /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Task 4
echo "[Task 4] Add Kernel settings"
cat >> /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

# Task 5
echo "[Task 5] Install containerd runtime"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null
apt-get install -qq -y apt-transport-https ca-certificates curl gnupg lsb-release >/dev/null
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -qq >/dev/null
apt-get install -qq -y containerd.io >/dev/null
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null

# Task 6
echo "[Task 6] Set up Kubernetes repo"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' > /etc/apt/sources.list.d/kubernetes.list

# Task 7
echo "[Task 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt-get update -qq >/dev/null
apt-get install -qq -y kubeadm kubelet kubectl >/dev/null

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
