#!/bin/bash
set -e

apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

usermod -aG docker ubuntu

mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Clone repository (REPLACE WITH YOUR GITHUB USERNAME)
git clone -b Precious-project https://github.com/Nifesimi-p/fusionpact-devops-challenge.git .

cat > .env << EOF
DATABASE_URL=${database_url}
GRAFANA_PASSWORD=${grafana_password}
EOF

docker-compose up -d

chown -R ubuntu:ubuntu /home/ubuntu/app

# Install Nginx and Certbot
apt install -y nginx certbot python3-certbot-nginx

# Configure Nginx as reverse proxy
cat > /etc/nginx/sites-available/default << 'NGINXCONF'
server {
    listen 80;
    server_name ${domain_name};

    location / {
        proxy_pass http://localhost:3000;  # Adjust port if your app uses different port
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXCONF

# Test and reload Nginx
nginx -t
systemctl restart nginx

# Wait for DNS propagation and get SSL certificate
sleep 60
certbot --nginx -d ${domain_name} --non-interactive --agree-tos --email ${ssl_email} --redirect

# Auto-renewal is enabled by default
systemctl enable certbot.timer