#!/bin/bash

# Redirect all output and errors to a log file
exec > /var/log/user-data.log 2>&1
set -ex   # Exit immediately if a command exits with a non-zero status

echo "📦 Updating & installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y openjdk-8-jre-headless docker.io

echo "🚀 Enabling & starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu && newgrp docker

echo "💾 Configuring 2GB swap space..."
SWAPFILE=/swapfile
if [ ! -f $SWAPFILE ]; then
  sudo fallocate -l 2G $SWAPFILE
  sudo chmod 600 $SWAPFILE
  sudo mkswap $SWAPFILE
  sudo swapon $SWAPFILE
  echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
fi

echo "⚙️ Setting vm.max_map_count for Elasticsearch..."
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf

echo "📂 Creating volumes & setting permissions..."
# Nexus
sudo mkdir -p /nexus-data
sudo chown -R 200 /nexus-data
sudo chmod -R 700 /nexus-data

# SonarQube
sudo mkdir -p /opt/sonarqube/data
sudo chmod -R 777 /opt/sonarqube/data

echo "🐳 Starting Nexus container..."
docker run -d \
  --name nexus \
  -p 8081:8081 \
  -v /nexus-data:/nexus-data \
  sonatype/nexus3

echo "🐳 Starting SonarQube container..."
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -e SONAR_JAVA_OPTS="-Xms512m -Xmx1g" \
  -v /opt/sonarqube/data:/opt/sonarqube/data \
  sonarqube:lts

echo "⏳ Waiting 60 seconds for services to initialize..."
sleep 60

echo "🔑 Nexus Admin Password:"
docker exec nexus cat /nexus-data/admin.password || echo "Nexus not ready yet."

echo "📊 Memory & Swap Usage (MB):"
free -m

echo "✅ Setup Complete!"
