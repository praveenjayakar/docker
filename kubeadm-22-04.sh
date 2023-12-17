#!/bin/bash
echo "Installing container runtime..."

# Update package index and install required packages
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lolcat

ufw disable
swapoff -a

echo "Disabling swap..."

# Disable swap for the current session
sudo swapoff -a

# Comment out the swap entry in /etc/fstab to make it persistent across reboots
sudo sed -i '/\sswap\s/s/^/#/' /etc/fstab

echo "Swap disabled successfully."


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

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl
sudo apt-mark hold kubectl

CNI_PLUGINS_VERSION="v1.3.0"
ARCH="amd64"
DEST="/opt/cni/bin"
sudo mkdir -p "$DEST"
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz" | sudo tar -C "$DEST" -xz

DOWNLOAD_DIR="/usr/local/bin"
sudo mkdir -p "$DOWNLOAD_DIR"

CRICTL_VERSION="v1.28.0"
ARCH="amd64"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz

RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
ARCH="amd64"
cd $DOWNLOAD_DIR
sudo curl -L --remote-name-all https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet}
sudo chmod +x *

RELEASE_VERSION="v0.16.2"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet
chown -R $USER:$USER /usr/local/bin/crictl

echo "Done!"
#kubeip=$(ip addr | grep -i eth | grep -i inet | awk '{print $2}'| cut -d "/" -f1)
#sudo kubeadm init --control-plane-endpoint=${kubeip} --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/containerd/containerd.sock

#kubeip=$(ip addr | grep -i eth | grep -i inet | awk '{print $2}'| cut -d "/" -f1)
#sudo kubeadm init --control-plane-endpoint=${kubeip} --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/containerd/containerd.sock
#curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml -O
#kubectl apply -f calico.yaml
#if you want to untaint the node to deploy pods on master node
#use this command kubectl taint nodes localhost node-role.kubernetes.io/control-plane:NoSchedule-
#in the name of localhost give the cluster name .

