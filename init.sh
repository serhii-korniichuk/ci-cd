#!/bin/bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker

# Run container
sudo docker run -d \
  --name web-ci-cd-app \
  --label com.centurylinklabs.watchtower.enable=true \
  -p 80:80 \
  skorniichuk/ci-cd:latest

# Run Watchtower
sudo docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --interval 60 \
  --label-enable
