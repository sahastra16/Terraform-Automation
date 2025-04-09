#!/bin/bash

# Redirect all output and errors to a log file
exec > /var/log/user-data.log 2>&1
set -ex  # Exit immediately if a command exits with a non-zero status

echo "===== STARTING EC2 SETUP ====="

echo ">> Updating system packages"
sudo apt-get update -y
sudo apt-get upgrade -y

echo ">> Installing dependencies"
sudo apt-get install -y curl unzip apt-transport-https ca-certificates gnupg lsb-release software-properties-common

echo ">> Installing Java (OpenJDK 11)"
sudo apt-get install -y openjdk-11-jdk

echo ">> Installing Docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo ">> Adding Docker repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo ">> Adding ubuntu user to docker group"
sudo usermod -aG docker ubuntu

echo ">> Enabling and starting Docker service"
sudo systemctl enable docker
sudo systemctl start docker

echo ">> Installing Docker Compose plugin"
DOCKER_CONFIG=/usr/lib/docker/cli-plugins
sudo mkdir -p $DOCKER_CONFIG
sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/docker-compose
sudo chmod +x $DOCKER_CONFIG/docker-compose

echo ">> Verifying Docker installation"
docker --version
docker compose version

echo ">> Pulling Jenkins Docker image"
docker pull jenkins/jenkins:lts

echo ">> Running Jenkins container"
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

echo "===== EC2 SETUP COMPLETE ====="
