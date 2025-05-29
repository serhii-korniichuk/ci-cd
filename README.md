
# CI/CD Deployment to AWS with GitHub Actions, Docker and Watchtower

This project demonstrates a complete CI/CD pipeline that deploys a static HTML+CSS website to AWS EC2 using Docker, GitHub Actions and Watchtower.

## 🚀 Technologies Used

- **Cloud Platform**: AWS EC2 (Free Tier)
- **CI/CD**: GitHub Actions
- **Containerization**: Docker
- **Auto-updates**: Watchtower
- **Container Registry**: Docker Hub
- **Local Dev Tool**: OrbStack (for macOS)

## 📁 Project Structure

```
/my-app
├── index.html
├── styles.css
└── Dockerfile
```

## 🧩 Dockerfile

```Dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
```

## ✅ Deployment Steps

1. **Create EC2 instance** (Ubuntu, t2.micro) on AWS with SSH access and open ports 22 (SSH) and 80 (HTTP).
2. **Install Docker**:
    ```bash
    sudo apt update
    sudo apt install docker.io -y
    ```
3. **Build and run your container locally (OrbStack)**:
    ```bash
    docker build -t ci-cd .
    docker run -d -p 80:80 ci-cd
    ```

4. **Push to GitHub and configure CI pipeline**.

## 🔐 Docker Hub Authentication

- Use **Access Token** instead of password.
- Add GitHub repository secrets:
    - `DOCKER_USERNAME`: your Docker Hub username
    - `DOCKER_PASSWORD`: Access Token (from Docker Hub > Security)

## 🧪 GitHub Actions Workflow (`.github/workflows/docker-publish.yml`)

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: skorniichuk/my-ci-cd-app:latest
```

## 🔁 Auto-Update with Watchtower

On the EC2 instance, run:

```bash
docker run -d   --name watchtower   -v /var/run/docker.sock:/var/run/docker.sock   containrrr/watchtower
```

## 🔄 What Happens

1. You commit to `main`.
2. GitHub builds & pushes the Docker image to Docker Hub.
3. Watchtower on your EC2 pulls and restarts the updated container automatically.

## 📌 Result

- Fully automated CI/CD pipeline with secure token-based auth.
- Deployment with no manual server interaction after commit.
