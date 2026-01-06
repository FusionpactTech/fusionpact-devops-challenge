#!/bin/bash

# AWS EC2 Deployment Script for Fusionpact DevOps Challenge
# This script sets up the application on a fresh Ubuntu EC2 instance

echo "🚀 Starting Fusionpact DevOps Challenge Deployment on AWS EC2"

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER

# Install Git
echo "📂 Installing Git..."
sudo apt install -y git

# Clone repository (replace with your forked repository)
echo "📥 Cloning repository..."
cd /home/ubuntu
git clone https://github.com/YOUR_USERNAME/fusionpact-devops-challenge.git
cd fusionpact-devops-challenge

# Set proper permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu/fusionpact-devops-challenge

# Build and start services
echo "🏗️ Building and starting services..."
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d

# Wait for services to start
echo "⏳ Waiting for services to initialize..."
sleep 30

# Check service status
echo "🔍 Checking service status..."
docker-compose -f docker-compose.prod.yml ps

# Test endpoints
echo "🧪 Testing endpoints..."
echo "Frontend Status:"
curl -I http://localhost:8080

echo -e "\nBackend Status:"
curl http://localhost:8000

echo -e "\nMetrics Endpoint:"
curl -I http://localhost:8000/metrics

# Display access information
echo "✅ Deployment Complete!"
echo "Frontend URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "Backend API: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8000"
echo "Metrics: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8000/metrics"

echo "📋 Security Group Requirements:"
echo "- Allow inbound HTTP (8080) from 0.0.0.0/0"
echo "- Allow inbound Custom TCP (8000) from 0.0.0.0/0"
echo "- Allow inbound SSH (22) from your IP"
