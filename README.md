
# CI/CD Deployment to AWS using Terraform (with GitHub Actions, Docker and Watchtower)

This project demonstrates how to deploy a static web application using Docker and AWS EC2, with CI/CD powered by GitHub Actions and infrastructure managed via Terraform.

## ⚙️ Technologies
- **AWS EC2 (Free Tier)**: Infrastructure for hosting the container
- **Terraform**: Infrastructure as Code for EC2 & security group
- **Docker**: Containerized Nginx serving static content
- **Watchtower**: Auto-updates containers on image push
- **GitHub Actions**: Automates Docker builds and deployments
- **S3 Backend**: Remote state management for Terraform
- **IAM User**: Used for GitHub Actions access to AWS

## 📦 Docker Hub Image

Repository: [skorniichuk/ci-cd](https://hub.docker.com/r/skorniichuk/ci-cd)

## 📁 Project Structure

```
ci-cd/
├── .github/
│   └── workflows/
│       ├── docker-image.yml         # CI pipeline for Docker image build & push to Docker Hub
│       └── terraform.yml            # CI pipeline for Terraform init, plan, apply & manual destroy
├── Dockerfile                       # Nginx-based Docker image serving static content
├── index.html                       # Static HTML page
├── styles.css                       # Styles for the HTML page
├── init.sh                          # EC2 startup script: installs Docker, runs container, sets up Watchtower
├── main.tf                          # Terraform config: EC2, Security Group, remote state via S3
├── .gitignore                       # Ignored files list
└── README.md                        # Project documentation
```

## 💎 How it works

This project implements a two-part CI/CD pipeline:

1. **Application Delivery** — builds and publishes a Docker image when changes are pushed.
2. **Infrastructure Provisioning** — deploys or updates AWS infrastructure using Terraform when triggered.

Both pipelines work together to automatically deliver a live application to an EC2 instance.

## 🧱 CI/CD Pipelines

### 🔹 `docker-image.yml` (Auto-build, lint & publish image)

- **Trigger**: Push to `main` branch
- **Does**:
  - Runs `htmllint` to validate HTML code quality
  - Builds Docker image from project source
  - Logs in to Docker Hub using GitHub Secrets
  - Pushes the image to Docker Hub (`skorniichuk/ci-cd:latest`)

> 🔍 `htmllint` helps catch HTML syntax errors and bad practices before deployment.

---

### 🔹 `terraform.yml` (Provision infrastructure)

- **Trigger**: Manual via GitHub UI (workflow_dispatch)
- **Does**:
  - Uses Terraform to provision EC2 instance and Security Group
  - Installs Docker using `init.sh` on the instance
  - Runs the latest Docker image and Watchtower for auto-updates

> 🔐 Uses AWS credentials from GitHub Secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

## ☁️ Terraform Remote State with AWS S3
To ensure consistent and centralized infrastructure management, this project uses a remote backend via AWS S3 to store the Terraform state file (terraform.tfstate).

> 🔍 Why Remote State?
Prevents conflicts when working in a team or using CI/CD.

Keeps state persistent even if the local environment is wiped.

Enables CI pipelines to safely track and manage infrastructure changes.

## 🔄 Auto-Update with Watchtower

Watchtower runs inside the EC2 instance and:
- Monitors the running container
- Pulls the latest Docker image automatically every 60 seconds
- Restarts the container when a new version is detected

This enables seamless application updates after pushing to `main`.

## 🚀 Manual Deployment Guide

This guide helps you set up fully automated deployment of a web application from GitHub to AWS EC2 using Docker and Watchtower.


### 1️⃣ Connect to EC2 via SSH

🔹 What you need:

- `.pem` SSH key file (e.g., `YOUR_KEY.pem`)
- Public IPv4 address from AWS EC2

🔹 Connect via terminal:

```bash
sudo ssh -i /path/to/YOUR_KEY.pem ubuntu@<EC2_IP>
```

---

### 2️⃣ Check Docker installation

🔹 Check Docker version:

```bash
docker --version
```

💡 If not installed:

```bash
sudo apt update
sudo apt install docker.io -y
```

🔹 List running containers:

```bash
sudo docker ps
```

---

### 3️⃣ Run container from Docker Hub

💡 Remove old container if it exists:

```bash
sudo docker rm -f web-ci-cd-app
```

🔹 Pull the latest image:

```bash
sudo docker pull skorniichuk/ci-cd:latest
```

🔹 Run the container with Watchtower support:

```bash
sudo docker run -d \
  --name web-ci-cd-app \
  --label com.centurylinklabs.watchtower.enable=true \
  -p 80:80 \
  skorniichuk/ci-cd:latest
```

---

### 4️⃣ Launch Watchtower

💡 Remove old container if it exists:

```bash
sudo docker rm -f watchtower
```

🔹 Run the Watchtower:

```bash
sudo docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --interval 60 \
  --label-enable
```

---

### 5️⃣ Verify everything

🔹 Check containers:

```bash
sudo docker ps
```
🔹 Check image:

```bash
sudo docker inspect web-ci-cd-app | grep Image
```

💡 You should see:

```
"Image": "skorniichuk/ci-cd:latest"
```

---

### 6️⃣ Test your app

🔹 Open in browser:

```
http://<EC2_IP>/
```

---

### 🎉 That's it! 

You now have a fully automated CI/CD pipeline with no manual server interaction after commit.

## 📄 License

MIT License