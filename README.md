Terraform Automation: Deploy Jenkins and SonarQube with Nexus

Overview

This project automates the provisioning of two EC2 instances using Terraform:

WebServer1: Installs Docker, Java, Docker Compose, and runs a Jenkins container.

WebServer2: Installs Docker and runs SonarQube and Nexus as Docker containers.

📁 Project Structure

terraform-vanila/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── install_webserver1.sh
├── install_webserver2.sh

🔧 Prerequisites

AWS Account & Credentials

Terraform installed (>= 1.5)

An AWS key pair for SSH access

Ubuntu-compatible AMI ID (e.g., ami-03f4878755434977f for ap-south-1)

🔨 Step-by-Step Setup

1. Define Variables (variables.tf)

variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
}

2. Terraform Configuration (main.tf)

Creates VPC, subnet, route tables, internet gateway.

Deploys two EC2 instances.

Uses templatefile() to inject user_data scripts.

Make sure to reference your key name and ensure templatefile() reads from your install scripts.

3. Install Scripts

install_webserver1.sh (Jenkins)

#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

sudo apt update && sudo apt install -y docker.io openjdk-17-jre-headless
sudo usermod -aG docker ubuntu && newgrp docker

sudo docker run -d \
  -p 8080:8080 -p 50000:50000 \
  --name jenkins \
  jenkins/jenkins:lts

install_webserver2.sh (SonarQube & Nexus)

#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

sudo apt update && sudo apt install -y docker.io openjdk-17-jre-headless
sudo usermod -aG docker ubuntu && newgrp docker

# Add swap memory fallback
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Run SonarQube
sudo docker run -d --name sonarqube \
  -p 9000:9000 \
  sonarqube

# Run Nexus
sudo docker run -d --name nexus \
  -p 8081:8081 \
  sonatype/nexus3

🚀 Deployment Steps

terraform init
terraform plan
terraform apply

✅ Post-Deployment Checks

1. SSH into instances

ssh -i your-key.pem ubuntu@<public-ip>

2. Verify Jenkins (on WebServer1)

docker ps    # Jenkins container should be running

Access via http://<public-ip>:8080

Get initial admin password:

docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword

3. Verify SonarQube & Nexus (on WebServer2)

docker ps    # Both containers should be running

SonarQube: http://<public-ip>:9000  (Default: admin/admin)

Nexus: http://<public-ip>:8081  (Default: admin / password from /nexus-data/admin.password)

🛠️ Troubleshooting

Issue: Software not installed after launch

Solution:

Check cloud-init logs:

cat /var/log/user-data.log

Ensure install_webserver*.sh scripts are executable and correctly referenced in templatefile().

Issue: Docker container fails due to memory

Solution:

Check container logs:

docker logs <container-id>

Add swap memory as shown above.

Issue: Permissions error using Docker

Solution:

Ensure the ubuntu user is added to the docker group:

sudo usermod -aG docker ubuntu && newgrp docker

📌 Notes

set -x in scripts enables logging of all shell commands.

Use templatefile() over file() for dynamic scripts.

Don't forget to destroy the infra when done:

terraform destroy

Happy Automating! 🚀

