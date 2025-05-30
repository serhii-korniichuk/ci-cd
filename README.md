
# CI/CD Deployment to AWS with GitHub Actions, Docker and Watchtower

This project demonstrates a complete CI/CD pipeline that deploys a static HTML + CSS website to AWS EC2 using Docker, GitHub Actions and Watchtower.

## 🚀 Technologies Used

- **Cloud Platform**: AWS EC2 (Free Tier)
- **CI/CD**: GitHub Actions
- **Containerization**: Docker
- **Container Registry**: Docker Hub
- **Auto-updates**: Watchtower

## 📁 Project Structure

```
/ci-cd
├── index.html
├── styles.css
└── Dockerfile
```

## 💎 How it works

1. You push changes to GitHub
2. GitHub Actions builds and pushes the image to Docker Hub
3. Watchtower checks for updates every 60 seconds
4. If there's a new image, it automatically restarts the container

# 🚀 Guide

This guide helps you set up fully automated deployment of a web application from GitHub to AWS EC2 using Docker and Watchtower.


### 1️⃣ Connect to EC2 via SSH

🔹 What you need:

- `.pem` SSH key file (e.g., `YOUR_KEY.pem`)
- Public IPv4 address from AWS EC2

🔹 Connect via terminal:

```bash
sudo ssh -i /path/to/KPI_LAB_KEY.pem ubuntu@<EC2_IP>
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
___

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

### 6️⃣ Test your app in the browser

Visit:

```
http://<EC2_IP>/
```

### 🎉 That's it! 

You now have a fully automated CI/CD pipeline with no manual server interaction after commit.
