#!/bin/bash
set -e

# Basic system updates and tools
apt-get update -y
apt-get install -y software-properties-common apt-transport-https wget curl git vim gnupg ca-certificates lsb-release

# Install Ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible >> /var/log/ansible-install.log 2>&1
echo "Ansible installed successfully" >> /var/log/ansible-install.log

# Install Git and clone repository
apt install -y git
git clone https://github.com/thani2808/first-ec2startandstop.git /opt/ansible-playbooks
echo "Git repo cloned successfully" >> /var/log/ansible-install.log

# Install VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
apt-get update
apt-get install -y code
echo "VS Code installed successfully" >> /var/log/ansible-install.log

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker
echo "Docker installed and started successfully" >> /var/log/ansible-install.log