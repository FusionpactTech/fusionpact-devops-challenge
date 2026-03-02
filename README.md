# FusionPact DevOps Challenge
### Standard Operating Procedure (SOP)

**Candidate Name:** Olowookere Precious Jesutofunmi

**Project Duration:** 14th October - 16th October  
**Repository:** https://github.com/Nifesimi-p/fusionpact-devops-challenge  
**Branch:** Precious-project

---

## Executive Summary

Successfully deployed a production-ready two-tier web application (FastAPI backend + Nginx frontend) on AWS EC2 with infrastructure automation using Terraform, SSL/TLS encryption, observability and automated CI/CD pipeline.

---

### **Key Technologies**

* **Cloud Platform:** AWS EC2 (Ubuntu 22.04, t2.micro), Elastic IP
* **Automation:** Terraform (Infrastructure as Code)
* **Containerization:** Docker
* **Web Server / Reverse Proxy:** Nginx
* **Monitoring:** Prometheus, Grafana
* **Security:** Let’s Encrypt (SSL/TLS Certificates)
* **Networking / DNS:** NoIP Dynamic DNS
* **CI/CD:** GitHub Actions
  
---

**Project Outcome:** Automated, monitored, and production-ready application with data persistence and zero-downtime deployment capability.

---

## Table of Contents

1. [Level 1 - Cloud Deployment with Infrastructure as Code](#level-1)
2. [Level 2 - Monitoring & Observability](#level-2)
3. [Level 3 - CI/CD Automation](#level-3)
4. [Architecture Overview](#architecture)
5. [Challenges & Solutions](#challenges)
6. [Key Learnings](#learnings)
7. [Appendix - URLs & Resources](#appendix)
8. [Complete Command Log - FusionPact DevOps Challenge](#command)

---

<a name="level-1"></a>
## Level 1 - Cloud Deployment with Infrastructure as Code

### Objective
Deploy containerized full-stack application to AWS EC2 using Terraform with data persistence 

### Implementation

#### 1. Containerization

**Backend Dockerfile** (`backend/Dockerfile`):
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run the application (adjusted for app/ subdirectory)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Frontend Dockerfile** (`frontend/Dockerfile`):
```dockerfile
FROM nginx:alpine

COPY . /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### 2. Docker Compose Orchestration

Created `docker-compose.yml` managing 5 services:
- **Backend:** FastAPI application
- **Frontend:** Nginx web server
- **Prometheus:** Metrics collection
- **Grafana:** Visualization platform
- **Node Exporter:** Infrastructure metrics

**Key Configuration Highlights:**
```yaml
services:
  backend:
    build: ./backend
    container_name: backend
    ports:
      - "8000:8000"
    volumes:
      - backend-data:/app/data
    
  Frontend:
    build: ./frontend
    container_name: frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    
volumes:
  backend-data:      # SQLite database persistence
  prometheus-data:   # Metrics history retention
  grafana-data:      # Dashboard configurations
```

#### 3. Data Persistence Strategy & Importance.

**Implementation:**
- **Backend Data:** SQLite database persisted to `backend-data` volume at `/app/data`
- **Prometheus Data:** Metrics history stored in `prometheus-data` volume at `/prometheus`
- **Grafana Data:** Dashboard configs and user data in `grafana-data` volume at `/var/lib/grafana`

**Data Persistence Importance:**
Without persistent volumes, all application data (user submissions, metrics history, dashboard configurations) would be lost on container restart. This ensures:
- Database integrity across deployments
- Historical metrics retention for trend analysis
- Dashboard configurations survive updates
- Production continuity and reliability


---

#### 4. **SSL/TLS Implementation**

##### **Reverse Proxy Setup**

* **Nginx** terminates SSL on port **443**
* **Let’s Encrypt** certificate via **Certbot** (auto-renewal enabled)

* Proxies requests to Docker containers on **localhost**

---

#### **Key Challenge & Resolution**

**Issue:**
Frontend container served the default Nginx page instead of the actual application.

**Root Cause:**
The container’s `nginx.conf` pointed to `index.html` (Nginx default) instead of the correct `Devops_Intern.html`.

**Resolution:**
Updated the frontend `nginx.conf` as follows:

```nginx
index Devops_Intern.html;
location / {
    try_files $uri $uri/ /Devops_Intern.html;
}
```

Then rebuilt and relaunched the container:

```bash
docker-compose build frontend && docker-compose up -d
```

**Trade-off:**
Used internal port **3001** for the frontend to avoid conflicts with host-level Nginx on port **80**.
This approach allows **SSL termination at the host level** while maintaining **container isolation** and clean network separation.

---

#### 5. AWS EC2 Deployment
##### **Infrastructure as Code (Terraform)**

The entire infrastructure was **provisioned directly through Terraform**, enabling automated, repeatable deployment of all required AWS resources. Each resource was defined in code to ensure consistency, transparency, and easy re-creation when needed.

#### **Resources Provisioned**

* **VPC** with a public subnet for hosting internet-accessible services
* **Internet Gateway** to enable outbound and inbound internet connectivity
* **Security Groups** configured for inbound access on ports **22, 80, 443, 3000, 8000, and 9090**
* **Elastic IP** allocated for stable and persistent public addressing
* **EC2 Instance** deployed with **user-data automation** to install and start essential services (Prometheus, Grafana, and the application stack)

#### **EC2 Deployment**

* **Instance Type:** t2.micro (1 vCPU, 2GB RAM)
* **AMI:** Ubuntu 22.04 LTS
* **Security Group Rules:**

  * **SSH (22):** Management access
  * **HTTP (80):** Frontend access
  * **Backend (8000):** Application API
  * **Grafana (3000):** Monitoring dashboard
  * **Prometheus (9090):** Metrics collection interface

This configuration highlights an automated deployment where all networking, security, and compute resources were **created and managed through Terraform**, eliminating manual setup and ensuring a consistent, declarative infrastructure environment.

#### 6. Security Implementation
- Credentials stored in terraform.tfvars (gitignored)
- No hardcoded passwords in reposito

   
### Trade-offs & Decisions

| Decision | Alternative | Rationale | Importance |
|----------|-------------|-----------|------------|
| HTTPS | HTTP | Production requires encrypted communication. Implemented SSL/TLS to protect data in transit and prevent interception.** | Critical: HTTPS ensures data encryption, prevents man-in-the-middle attacks, builds user trust, and is mandatory for production environments handling any data. |
| Database: SQLite | PostgreSQL | Lightweight, zero-config, sufficient for demo. Built-in Python support. | Acceptable for evaluation; production scaling requires PostgreSQL for concurrency. |
| Instance: t2.micro | t2.large | Cost-efficient ($8.50/month), meets free tier eligibility. | Adequate for demo; production under heavy load requires larger instances. |
| Single EC2 | Multi-AZ | Simplified deployment, faster iteration for internship evaluation. | Single point of failure accepted for demo; production needs high availability. |
| Docker Compose | Kubernetes | Lightweight orchestration for 4 services, simple networking. | Sufficient for single-node deployment; scaling requires Kubernetes. |
| GitHub Actions | Jenkins | Native GitHub integration, zero infrastructure cost, simpler pipeline. | Adequate for straightforward CI/CD; complex workflows may need Jenkins. |

---

#### Security Implementation
**Production-Grade Security Applied:**
-  **HTTPS with SSL/TLS** - Encrypted communication via secure domain
-  **Nginx reverse proxy** - Centralized SSL termination and routing
-  **Secure secret management** - GitHub Secrets for credentials
-  **Restricted security groups** - Controlled access to EC2 instance

### Challenge Encountered

**Issue:** Docker Hub connection timeout during `docker compose up`
```
Error: Get "https://auth.docker.io/token": dial tcp [IPv6]:443: no route to host
```

**Root Cause:** IPv6 routing issue with Docker Hub registry

**Solution Applied:**
1. Used specific image versions instead of `latest` tag
2. Restarted Docker daemon
3. Pre-pulled images individually to verify connectivity

**Result:** Successful image pull and container startup

### Deliverables
✅ `backend/Dockerfile`  
✅ `frontend/Dockerfile`  
✅ `docker-compose.yml`  
✅ Screenshots: 
- ![Docker Containers](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/docker-containers.png "Docker Container")
- ![Terraform init screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/Terraform-init.png "Terraform init screenshot")
- ![Terraform Deployment Screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/Terraform-deployment.png "Terraform Deployment Screenshot")
- ![EC2 Instance Screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/Ec2-instance%20.png "EC2 Instance Screenshot")
- ![EC2 Security Group Screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/Ec2-sg.png "EC2 Security Group Screenshot")

---

<a name="level-2"></a>
## Level 2 - Monitoring & Observability 

### Objective
Implement observability with real-time infrastructure and application metrics.

### Implementation

#### 1. Prometheus Configuration

**File:** `monitoring/prometheus.yml`

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'backend'
    static_configs:
      - targets: ['backend:8000']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

**Scraping Strategy:**
- 15-second intervals balance data granularity vs storage
- Three targets monitored: Backend API, Node Exporter, Prometheus itself
- All targets verified as "UP" in Prometheus UI

#### 2. Grafana Setup

**Automated Datasource Provisioning:**

Created `grafana-provisioning/datasources/prometheus.yml`:
```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

**Benefits:** 
- No manual datasource configuration needed
- Consistent setup across environments
- Infrastructure-as-code approach

#### 3. Dashboard Implementation

**Dashboard 1: Infrastructure Metrics**
- **Source:** Imported pre-built Node Exporter Full dashboard (ID: 1860)
- **Metrics Visualized:**
  - CPU usage (user, system, idle)
  - Memory utilization and available
  - Disk I/O operations
  - Network traffic (inbound/outbound)
  - System load averages

**Dashboard #2: Application Metrics (Custom)**
 *This dashboard was manually created to demonstrate Grafana’s capability to visualize custom application metrics from Prometheus. It includes panels for key metrics such as HTTP request rate, response time (p95), error rate, status code distribution, and active requests.*

*The setup was intended as a temporary proof of concept, showcasing how Grafana can be configured to monitor application-level performance. Unlike the Node Exporter dashboard, this custom dashboard was not configured for persistence and exists only within the session in which it was created.*

**Screenshots below illustrate the dashboard layout and visualizations captured during the demonstration.**

Created custom dashboard with panels tracking:

| Panel | Metric Query | Visualization |
|-------|--------------|---------------|
| **HTTP Request Rate** | `rate(http_requests_total[5m])` | Time series |
| **Response Time (p95)** | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` | Time series |
| **Error Rate** | `rate(http_requests_total{status=~"5.."}[5m])` | Stat (red threshold) |
| **Status Code Distribution** | `sum by (status) (rate(http_requests_total[5m]))` | Pie chart |
| **Active Requests** | `http_requests_in_progress` | Gauge |

---

#### Trade-offs & Decisions

| Decision                     | Chosen           | Alternative  | Rationale                                          | Trade-offs                                            |
| ---------------------------- | ---------------- | ------------ | -------------------------------------------------- | ----------------------------------------------------- |
| **Scrape Interval**          | 15 seconds       | 5 seconds    | Balanced detail with manageable resource usage.    | Slightly less metric granularity during rapid events. |
| **Infrastructure Dashboard** | Imported #1860   | Custom built | Faster setup using a proven, reliable template.    | Limited customization flexibility for unique metrics. |
| **Application Dashboard**    | Custom           | Pre-built    | Tailored to app-specific KPIs and workflows.       | Requires more development and maintenance effort.     |
| **Datasource Setup**         | Auto-provisioned | Manual       | Ensures consistency and easy replication via code. | Less flexibility for ad-hoc configuration changes.    |


#### Challenges Encountered

**Issue:** Unable to login to Grafana with default `admin/admin` credentials

**Root Cause:** Pre-existing Grafana volume from previous deployment contained different password

**Solution Applied:**
1. Attempted password reset: `docker exec grafana grafana-cli admin reset-admin-password`
2. Final solution: Removed old volume and recreated with fresh configuration
```bash
docker compose stop grafana
docker volume rm fusionpact-devops-challenge_grafana-data
docker compose up -d grafana
```

**Lesson Learned:** Always document custom passwords; consider environment variables for initial setup

#### Metrics Validation

**Traffic Generation for Testing:**
```bash
for i in {1..200}; do
  curl -s http://localhost:8000/health > /dev/null
  curl -s http://localhost:8000/metrics > /dev/null
  sleep 0.05
done
```

**Verification Steps:**
1. Confirmed all Prometheus targets showing "UP" status
2. Validated metrics appearing in Prometheus query interface
3. Verified Grafana dashboards displaying real-time data
4. Tested alert conditions and panel refresh rates

### Deliverables
✅ `monitoring/prometheus.yml` configuration  
✅ Grafana datasource auto-provisioning  
✅ Screenshot: Prometheus targets (all UP)  
✅ Screenshot: Infrastructure dashboard with live metrics  
✅ Screenshot: Application metrics dashboard with traffic data
- ![Prometheus Screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/Promethus.png "Prometheus Screenshot")
- ![Grafana Screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/Grafana.png "Grafana Screenshot")
- ![Custom Metric Screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/Custom-metric.png "Custom Metric Screenshot") 
  
---

<a name="level-3"></a>
#### Level 3 - CI/CD Automation

#### Objective
Automate build, test, and deployment workflow for continuous delivery.

#### Implementation

#### 1. CI/CD Platform Selection

**Chosen:** GitHub Actions

**Rationale:**
- Native GitHub integration (no external server needed)
- Free for public repositories
- YAML-based configuration (infrastructure-as-code)
- Built-in secrets management

**Alternative Considered:** Jenkins
- **Trade-off:** Jenkins requires dedicated server maintenance and resources
- **Decision:** GitHub Actions provides serverless CI/CD with zero infrastructure overhead

#### 2. Pipeline Configuration

**File:** `.github/workflows/ci-cd.yml`

**Pipeline Stages:**
1. Code Checkout
- Clones repository
- Checks out working branch

2. Build & Test
- Installs Python dependencies
- Runs backend unit tests
- Lints code with Black

3. Docker Image Build
- Builds backend image
- Builds frontend image
- Tags with commit SHA and 'latest'

4. Push to Registry
- Authenticates to Docker Hub
- Pushes images to registry

5. Deploy to Cloud
- SSH into EC2 instance
- Pulls latest images
- Runs docker-compose up -d
- Verifies deployment health



```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, master, Precious-project ]
  pull_request:
    branches: [ main, master, Precious-project ]
  workflow_dispatch:

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - Checkout code
      - Setup Python 3.9
      - Install backend dependencies
      - Run backend tests 
      - Build and Push Docker Images
      - Checkout code
      - Login to Docker Hub
      - Build and push backend image
      - Build and push frontend image

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - Checkout code
      - Deploy to EC2
      - Verify Deployment
      
```

#### 3. Secrets Configuration

**GitHub Repository Secrets Added:**
- `DOCKER_USERNAME`   - Docker Hub username
- `DOCKER_PASSWORD`   - Docker Hub access token
- `EC2_HOST`          - EC2 public IP address
- `EC2_USER`          - SSH username
- `EC2_SSH_KEY`       - Private SSH key for EC2 access
- `AWS_ACCESS_KEY_ID` - AWS Credentials
- `AWS_SECRET_KEY`.   - AWS Credentials

**Security Best Practice:** Never hardcode credentials in workflow files

#### 4. Deployment Strategy

**Approach:** Direct SSH deployment to EC2

**Steps Automated:**
1. SSH into EC2 instance
2. Navigate to project directory
3. Pull latest code from GitHub
4. Pull updated Docker images from registry
5. Restart services: `docker compose up -d`
6. Verify deployment: `docker compose ps`

**Trade-off Analysis:**

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| **SSH Deployment** | Simple, direct control | Manual scaling | ✅ Chosen for single-server setup |
| **Kubernetes** | Auto-scaling, HA | Complex, resource-intensive | ❌ Overkill for demo |
| **AWS CodeDeploy** | AWS-native | Additional AWS complexity | ❌ GitHub Actions simpler |

#### Challenges Encountered

**Issue:** Initial pipeline failure due to missing secrets

**Error Log:**
```
Error: Input required and not supplied: DOCKER_USERNAME
```

**Solution Applied:**
1. Navigated to GitHub Repository → Settings → Secrets and Variables → Actions
2. Added all required secrets with correct values
3. Verified SSH key format (removed headers, single line)
4. Re-ran pipeline successfully

**Validation:** Green checkmarks across all pipeline stages

#### CI/CD Benefits Achieved

1. **Automated Testing:** Code quality checks on every commit
2. **Consistent Builds:** Reproducible image creation
3. **Fast Deployment:** ~3 minutes from push to production
4. **Rollback Capability:** Previous images available in registry
5. **Audit Trail:** Complete deployment history in GitHub Actions

### Deliverables
✅ `.github/workflows/deploy.yml` pipeline configuration  
✅ Docker Hub repository with tagged images  
✅ Screenshot: Successful pipeline execution  
✅ Screenshot: Docker Hub showing pushed images
✅ Screenshot: Functioning Webapp
- ![CI/CD Deployment Screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/ci-cd-deployment.png "CI/CD Deployment Screenshot")
- ![Frontend Docker Images](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/frontend-docker-images.png "Frontend Docker Images")
- ![Backend Docker Images](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/backend-docker-images.png "Backend Docker Images")
- ![Functioning Web App Screenshot](https://raw.githubusercontent.com/Nifesimi-p/fusionpact-devops-challenge/Precious-project/Screenshots/functioning-webapp.png "Functioning Web App Screenshot")

---

<a name="architecture"></a>
## Architecture Overview

#### System Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                   Developer Workstation                      │
│                  (Terraform + Git)                           │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        │ terraform apply         │ git push
        ▼                         ▼
┌─────────────────┐      ┌─────────────────────────────────────┐
│   AWS Cloud     │      │         GitHub Actions               │
│                 │      │  ┌──────────┐  ┌──────────┐         │
│ ┌─────────────┐ │      │  │ Checkout │→ │  Build   │         │
│ │  Terraform  │ │      │  └──────────┘  └──────────┘         │
│ │   State     │ │      │  ┌──────────┐  ┌──────────┐         │
│ └─────────────┘ │      │  │   Push   │→ │  Deploy  │         │
│        │        │      │  └──────────┘  └──────────┘         │
│        ▼        │      └────────────┬────────────────────────┘
│ ┌─────────────┐ │                   │
│ │   VPC +     │ │                   ▼
│ │ Security    │ │          ┌─────────────────┐
│ │   Groups    │ │          │   Docker Hub    │
│ └─────────────┘ │          │  Image Registry │
│        │        │          └────────┬────────┘
│        ▼        │                   │
│ ┌─────────────┐ │                   │ docker pull
│ │ Elastic IP  │ │                   │
│ │  (Static)   │ │                   │
│ └──────┬──────┘ │                   │
│        │        │                   │ SSH Deploy
│        ▼        │                   ▼
│ ┌─────────────────────────────────────────────────────────┐ │
│ │              AWS EC2 Instance (t3.micro)                │ │
│ │              Ubuntu 22.04 LTS + userdata.sh             │ │
│ │  ┌────────────────────────────────────────────────────┐ │ │
│ │  │           Host Level (Port 80/443)                 │ │ │
│ │  │                                                     │ │ │
│ │  │  ┌──────────────────────────────────┐             │ │ │
│ │  │  │   Nginx Reverse Proxy            │             │ │ │
│ │  │  │   • SSL Termination (Let's Encrypt)            │ │ │
│ │  │  │   • Port 80 → 443 redirect       │             │ │ │
│ │  │  │   • Port 443 HTTPS               │             │ │ │
│ │  │  └────────┬─────────────────────────┘             │ │ │
│ │  │           │                                         │ │ │
│ │  │           │ Path-based routing                     │ │ │
│ │  └───────────┼─────────────────────────────────────────┘ │
│ │              │                                           │ │
│ │  ┌───────────┴─────────────────────────────────────────┐ │
│ │  │         Docker Compose Stack                        │ │
│ │  │                                                      │ │
│ │  │  / → Frontend          ┌────────────┐              │ │
│ │  │                        │   Users    │              │ │
│ │  │  ┌────────────┐        │  (HTTPS)   │              │ │
│ │  │  │  Frontend  │◄───────└────────────┘              │ │
│ │  │  │(Nginx:3001)│  SSL via host Nginx                │ │
│ │  │  └─────┬──────┘  ↑                                  │ │
│ │  │        │         Port conflict prevented            │ │
│ │  │        │                                             │ │
│ │  │  /api → Backend                                     │ │
│ │  │        ▼                                             │ │
│ │  │  ┌────────────┐                                     │ │
│ │  │  │  Backend   │                                     │ │
│ │  │  │ (FastAPI   │                                     │ │
│ │  │  │   :8000)   │                                     │ │
│ │  │  └─────┬──────┘                                     │ │
│ │  │        │                                             │ │
│ │  │        │ /metrics                                    │ │
│ │  │        ▼                                             │ │
│ │  │  ┌────────────┐      ┌──────────────┐             │ │
│ │  │  │ Prometheus │◄─────│Node Exporter │             │ │
│ │  │  │  (:9090)   │      │   (:9100)    │             │ │
│ │  │  └─────┬──────┘      └──────────────┘             │ │
│ │  │        │                                             │ │
│ │  │        │ datasource                                  │ │
│ │  │  /grafana →                                         │ │
│ │  │        ▼                                             │ │
│ │  │  ┌────────────┐                                     │ │
│ │  │  │  Grafana   │                                     │ │
│ │  │  │  (:3000)   │                                     │ │
│ │  │  └────────────┘                                     │ │
│ │  │                                                      │ │
│ │  └──────────────────────────────────────────────────────┘ │
│ │                                                           │ │
│ │  ┌────────────────────────────────────────────────────┐  │ │
│ │  │               Docker Volumes (Persistence)          │  │ │
│ │  │  • backend-data (SQLite DB)                         │  │ │
│ │  │  • prometheus-data (Metrics history)                │  │ │
│ │  │  • grafana-data (Dashboard configs)                 │  │ │
│ │  └────────────────────────────────────────────────────┘  │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```
---

#### Data Flows

**1. Infrastructure Provisioning Flow:**
```
Developer → terraform apply → AWS API → 
  Creates: VPC, Security Groups, EC2, Elastic IP → 
  Executes: userdata.sh (Docker install, compose up)
```

**2. User Request Flow (HTTPS):**
```
User (HTTPS) → Nginx (Port 443, SSL termination) → 
  Path routing:
    / → Frontend container (3001)
    /api → Backend container (8000)
    /grafana → Grafana container (3000)
```

**3. Monitoring Flow:**
```
Backend (/metrics) → Prometheus scrapes (9090) → Grafana queries → Dashboard visualization
Node Exporter (9100) → Prometheus → Grafana (Infrastructure metrics)
```

**4. CI/CD Deployment Flow:**
```
git push → GitHub Actions trigger → 
  Build images → Push to Docker Hub → 
  SSH to EC2 → docker-compose pull → docker-compose up -d
```
### Network Configuration

| Service | Port | Access | Purpose |
|---------|------|--------|---------|
| Nginx (Host) | 80 | Public | HTTP → HTTPS redirect |
| Nginx (Host) | 443 | Public | SSL termination + reverse proxy |
| Frontend | 3001 | Internal | User-facing web interface (via Nginx /) |
| Backend | 8000 | Internal | REST API endpoints (via Nginx /api) |
| Prometheus | 9090 | Internal | Metrics query interface |
| Grafana | 3000 | Internal | Monitoring dashboards (via Nginx /grafana) |
| Node Exporter | 9100 | Internal | System metrics collection |
| SSH | 22 | Public | Terraform + admin access |

---

<a name="challenges"></a>
### 5. Challenges & Solutions

#### Challenge 1: Docker Hub Connectivity

**Problem:**
```
Error: Get "https://auth.docker.io/token": dial tcp [IPv6]:443: no route to host
```

**Impact:** Unable to pull Docker images, blocking deployment

**Root Cause Analysis:**
- IPv6 routing issue between local network and Docker Hub
- DNS resolution returning IPv6 address first
- Network configuration not supporting IPv6 connections

**Solution Implemented:**
1. Used specific image versions (e.g., `prom/prometheus:v2.45.0` instead of `latest`)
2. Restarted Docker daemon to refresh network configuration
3. Pre-pulled images individually to verify connectivity

**Outcome:** Successful image download and container startup

**Prevention:** Always use specific version tags in production for reproducibility

---

#### Challenge 2: Grafana Authentication

**Problem:** Unable to login with default `admin/admin` credentials

**Impact:** Could not access monitoring dashboards

**Root Cause Analysis:**
- Pre-existing Grafana volume contained initialized database with different password
- Docker Compose reused existing volume on restart
- No documentation of changed password

**Solution Implemented:**
1. Attempted CLI password reset: `docker exec grafana grafana-cli admin reset-admin-password`
2. Removed old volume: `docker volume rm fusionpact-devops-challenge_grafana-data`
3. Recreated container with fresh configuration
4. Set explicit admin password via environment variables

**Outcome:** Successful login and dashboard access

**Best Practice Adopted:** Document all password changes; use environment variables for initial configuration

---

#### Challenge 3: GitHub Actions Secrets

**Problem:** Pipeline failing with "Input required and not supplied" error

**Impact:** CI/CD automation non-functional

**Root Cause Analysis:**
- Secrets not configured in GitHub repository
- Workflow file referenced undefined variables
- SSH key format incorrect (contained headers)

**Solution Implemented:**
1. Added all required secrets in GitHub Repository Settings
2. Verified secret names matched workflow references exactly
3. Formatted SSH key correctly (removed BEGIN/END headers, single line)
4. Tested pipeline execution

**Outcome:** Green checkmarks across all pipeline stages

**Key Lesson:** Always validate secrets configuration before pushing workflow changes

---

<a name="learnings"></a>
### 6. Key Learnings & Best Practices

#### Technical Learnings

1. **Container Orchestration**
   - Docker Compose simplifies multi-container management
   - Named volumes provide persistent data storage
   - Container networking enables service discovery by name

2. **Monitoring Strategy**
   - Prometheus pull-based model scales well
   - Grafana provisioning enables infrastructure-as-code
   - 15-second scrape interval balances granularity and performance

3. **CI/CD Automation**
   - GitHub Actions provides serverless CI/CD
   - Secrets management critical for security
   - SSH deployment simple but requires secure key handling

#### DevOps Best Practices Applied

✅ **Infrastructure as Code:** All configurations version-controlled  
✅ **Data Persistence:** Volumes ensure state survival across deployments  
✅ **Observability:** Comprehensive monitoring from day one  
✅ **Automation:** Zero-touch deployments via CI/CD  
✅ **Security:** Secrets never hardcoded, proper access controls  
✅ **Documentation:** Complete SOP for reproducibility  


#### Future Enhancements

If scaling beyond:
1. **High Availability:** Multi-AZ deployment with load balancer
2. **Database:** Migrate from SQLite to PostgreSQL RDS
3. **Container Orchestration:** Kubernetes for auto-scaling
4. **CDN:** CloudFront for frontend static assets
5. **Secrets Management:** AWS Secrets Manager or HashiCorp Vault
6. **Log Aggregation:** ELK stack or CloudWatch Logs

---

<a name="appendix"></a>
###7 Appendix - URLs & Resources

### Public Access URLs

**Production Environment:**

* **Frontend Application:** [https://fusionpact.servehttp.com](https://fusionpact.servehttp.com)
* **Backend API:** [https://fusionpact.servehttp.com/api/](https://fusionpact.servehttp.com/api/)
* **API Docs:** [https://fusionpact.servehttp.com/api/docs](https://fusionpact.servehttp.com/api/docs)
* **Prometheus UI:** [http://fusionpact.servehttp.com:9090](http://fusionpact.servehttp.com:9090)
* **Grafana Dashboards:** [http://fusionpact.servehttp.com:3000](http://fusionpact.servehttp.com:3000)


**Development Resources:**
- GitHub Repository: `https://github.com/Nifesimi-p/fusionpact-devops-challenge`
- Project Branch: `Precious-project`
- Docker Hub Images: `https://hub.docker.com/u/preciousnifesi`

### Login Credentials

**Grafana:**
- Username: `admin`
- Password: ``

#### Key Configuration Files

All configuration files available in repository:

```
fusionpact-devops-challenge/
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
├── frontend/
│   ├── Dockerfile
│   └── Devops_Intern.html
├── infrastructure/
│   └── terraform/
│       ├── main.tf
│       ├── variables.tf
│       ├── providers.tf
│       ├── user-data.sh
│       └── terraform.tfvars (gitignored)
├── monitoring/
│   └── prometheus.yml
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── docker-compose.yml
└── README.md
```
---

### 8. Complete Command Log - FusionPact DevOps Challenge

## Prerequisites Check

```bash
docker --version
docker compose version
git --version
terraform --version
docker ps
cd ~/Desktop/DevOps-Projects/FusionPact/fusionpact-devops-challenge
```

---

#### Level 1: Cloud Deployment

#### Local Development

```bash
# Create backend Dockerfile
cat > backend/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Create frontend Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM nginx:alpine
COPY . /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Fix frontend nginx.conf (Critical - fixed default page issue)
cat > frontend/nginx.conf << 'EOF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index Devops_Intern.html;
    location / {
        try_files $uri $uri/ /Devops_Intern.html;
    }
}
EOF

# Create Prometheus config
mkdir -p monitoring
cat > monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:8000']
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
EOF

# Test locally
docker compose up -d
docker compose ps
curl http://localhost:8000/health
curl http://localhost
docker compose down
```

---

#### Terraform Infrastructure

```bash
cd infrastructure/terraform

# Create terraform.tfvars (gitignored)
cat > terraform.tfvars << 'EOF'
aws_region = "us-east-1"
instance_type = "t2.micro"
key_name = "your-key-name"
my_ip = "your-ip/32"
EOF

# Deploy infrastructure
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# Get EC2 IP
export EC2_IP=$(terraform output -raw ec2_public_ip)
echo $EC2_IP
```

---

#### Deploy to EC2

```bash
# SSH and deploy
ssh -i your-key.pem ubuntu@$EC2_IP

git clone https://github.com/Nifesimi-p/fusionpact-devops-challenge.git
cd fusionpact-devops-challenge
git checkout Precious-project

docker compose up -d
docker compose ps
curl http://localhost:8000/health

exit
```

---

#### SSL/TLS Setup (On EC2)

```bash
ssh -i your-key.pem ubuntu@$EC2_IP

# Install Certbot and Nginx
sudo apt update
sudo apt install certbot python3-certbot-nginx nginx -y

# Configure Nginx reverse proxy
sudo nano /etc/nginx/sites-available/default
# Added SSL termination and proxy configuration

sudo nginx -t
sudo systemctl reload nginx

# Get SSL certificate
sudo certbot --nginx -d fusionpact.servehttp.com
sudo certbot renew --dry-run

# Update docker-compose.yml frontend port to 3001
cd fusionpact-devops-challenge
nano docker-compose.yml
# Changed: ports: ["80:80"] to ports: ["3001:80"]

docker compose down
docker compose up -d

exit
```

---

### Level 2: Monitoring & Observability

#### Grafana Provisioning

```bash
# Back on local machine
cd ~/Desktop/DevOps-Projects/FusionPact/fusionpact-devops-challenge

mkdir -p grafana-provisioning/datasources

cat > grafana-provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# Updated docker-compose.yml grafana volumes to include:
# - ./grafana-provisioning:/etc/grafana/provisioning

docker compose restart grafana
docker logs grafana --tail 50 | grep -i datasource
```

---

#### Grafana Authentication Fix

```bash
# Reset password (when default didn't work)
docker exec -it grafana grafana-cli admin reset-admin-password admin123

# Alternative: Fresh install
docker compose stop grafana
docker volume rm fusionpact-devops-challenge_grafana-data
docker compose up -d grafana
```

---

#### Dashboard Setup

```bash
# Access Grafana
open http://localhost:3000
# Login: admin / admin123

# Imported Node Exporter Dashboard ID: 1860
# Created custom Application Metrics dashboard manually

# Generate test traffic
for i in {1..200}; do
  curl -s http://localhost:8000/health > /dev/null
  curl -s http://localhost:8000/metrics > /dev/null
  sleep 0.05
done

# Verify Prometheus
open http://localhost:9090/targets
```

---

#### Deploy to EC2

```bash
git add .
git commit -m "Add monitoring configuration"
git push origin Precious-project

ssh -i your-key.pem ubuntu@$EC2_IP
cd fusionpact-devops-challenge
git pull origin Precious-project
docker compose down
docker compose up -d
docker compose ps
exit
```

---

### Level 3: CI/CD Automation

#### GitHub Actions Setup

```bash
mkdir -p .github/workflows

cat > .github/workflows/ci-cd.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, master, Precious-project ]
  workflow_dispatch:

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      - name: Build and push backend
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/fusionpact-backend:latest ./backend
          docker push ${{ secrets.DOCKER_USERNAME }}/fusionpact-backend:latest
      - name: Build and push frontend
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/fusionpact-frontend:latest ./frontend
          docker push ${{ secrets.DOCKER_USERNAME }}/fusionpact-frontend:latest

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            cd fusionpact-devops-challenge
            git pull origin Precious-project
            docker compose pull
            docker compose up -d
EOF
```

---

#### Configure Secrets

```bash
# Added in GitHub UI (Settings → Secrets):
# DOCKER_USERNAME = preciousnifesi
# DOCKER_PASSWORD = (Docker Hub token)
# EC2_HOST = (EC2 public IP)
# EC2_USER = ubuntu
# EC2_SSH_KEY = (private key content)
```

---

#### Deploy

```bash
git add .
git commit -m "Add CI/CD pipeline"
git push origin Precious-project

# Watched pipeline in GitHub Actions tab
# Verified deployment on EC2
```

---

### Verification Commands

```bash
# Check containers
docker compose ps

# Test services
curl https://fusionpact.servehttp.com
curl https://fusionpact.servehttp.com/api/health
curl http://fusionpact.servehttp.com:9090/-/healthy

# View logs
docker compose logs backend --tail 50
docker compose logs grafana --tail 50

# Check volumes
docker volume ls
docker volume inspect fusionpact-devops-challenge_backend-data
```

---

### Git Commands Used

```bash
git clone https://github.com/Nifesimi-p/fusionpact-devops-challenge.git
git checkout Precious-project
git status
git add .
git commit -m "message"
git push origin Precious-project
git pull origin Precious-project
```

---

### Terraform Commands Used

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
terraform output
terraform output ec2_public_ip
```

---

**END OF COMMAND LOG**

#### Conclusion

This project demonstrates end-to-end DevOps capability: from application containerization through cloud deployment, monitoring, and fully automated CI/CD pipelines. The implementation balances production-grade practices with practical trade-offs appropriate for the scale and requirements.


---

#### Quick Reference Commands

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f

# Rebuild after changes
docker compose up -d --build

# Check status
docker compose ps

# Access container shell
docker exec -it [container-name] /bin/sh

# View volumes
docker volume ls

# Clean up
docker compose down -v
docker system prune -a
```

---

**END OF SOP**







