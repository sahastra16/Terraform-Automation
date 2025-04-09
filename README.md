🚀 Terraform-Powered DevOps Deployment: Jenkins + SonarQube + Nexus
Welcome to your all-in-one Terraform automation setup for deploying a modern DevOps stack on AWS! This project spins up two EC2 instances and auto-installs:

WebServer1: Docker, Java, Docker Compose, Jenkins

WebServer2: Docker, Java, SonarQube, Nexus Repository Manager

📁 Project Structure
bash
Copy
Edit
terraform-vanila/
├── main.tf                  # Core Terraform config
├── variables.tf             # Input variable definitions
├── terraform.tfvars         # Values for variables
├── install_webserver1.sh    # Jenkins setup
├── install_webserver2.sh    # SonarQube + Nexus setup
⚙️ Prerequisites
✅ An AWS Account

✅ Terraform v1.5+

✅ A valid AWS Key Pair (.pem) for SSH

✅ Ubuntu-based AMI (e.g., ami-03f4878755434977f for ap-south-1)

🏗️ What This Deploys
Instance	Services Installed	Ports Exposed
WebServer1	Java, Docker, Jenkins	8080 (Jenkins), 50000
WebServer2	Java, Docker, SonarQube, Nexus Repository	9000 (SonarQube), 8081
📦 Setup Instructions
1️⃣ Define Your Variables (variables.tf)
hcl
Copy
Edit
variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
}
2️⃣ Edit Terraform Configuration (main.tf)
Use the templatefile() function to pass install scripts to EC2's user_data.

⚙️ Installation Scripts
🖥️ install_webserver1.sh (Jenkins Setup)
bash
Copy
Edit
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

sudo apt update && sudo apt install -y docker.io openjdk-17-jre-headless
sudo usermod -aG docker ubuntu && newgrp docker

docker run -d \
  -p 8080:8080 -p 50000:50000 \
  --name jenkins \
  jenkins/jenkins:lts
🖥️ install_webserver2.sh (SonarQube + Nexus Setup)
bash
Copy
Edit
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

sudo apt update && sudo apt install -y docker.io openjdk-17-jre-headless
sudo usermod -aG docker ubuntu && newgrp docker

# Add swap memory for JVM-heavy apps
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Run SonarQube
docker run -d --name sonarqube -p 9000:9000 sonarqube

# Run Nexus
docker run -d --name nexus -p 8081:8081 sonatype/nexus3
🚀 Deploy the Infrastructure
bash
Copy
Edit
terraform init
terraform plan
terraform apply
🔎 Post-Deployment Verification
✅ SSH into the Instances
bash
Copy
Edit
ssh -i your-key.pem ubuntu@<public-ip>
✅ Jenkins (WebServer1)
Access UI: http://<web1-public-ip>:8080

Get initial admin password:

bash
Copy
Edit
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
✅ SonarQube & Nexus (WebServer2)
SonarQube: http://<web2-public-ip>:9000
Login: admin / admin

Nexus: http://<web2-public-ip>:8081
Login: admin
Password:

bash
Copy
Edit
docker exec -it nexus cat /nexus-data/admin.password
🧯 Troubleshooting Guide
🔹 EC2 Launched but Software Not Installed?
bash
Copy
Edit
cat /var/log/user-data.log
Check for permission errors, download failures, or syntax errors in your script.

🔹 Nexus/SonarQube Crashing?
JVM memory issues are common. Check container logs:

bash
Copy
Edit
docker logs <container-id>
Add swap memory (already included in install_webserver2.sh).

🔹 Docker Command Fails with Permissions Error?
bash
Copy
Edit
sudo usermod -aG docker ubuntu && newgrp docker
💣 Clean Up
When you're done:

bash
Copy
Edit
terraform destroy
🙌 Wrap-up
You've now got a fully automated setup for your DevOps tooling with Terraform, Docker, and AWS. Whether you're practicing CI/CD or just exploring infrastructure as code—this stack is a powerful foundation to build upon. 🎯

