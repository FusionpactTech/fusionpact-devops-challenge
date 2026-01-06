<p align="center">
  <img src="https://raw.githubusercontent.com/Fusionpact-Org/assets/main/fusionpact-hero.gif" alt="Fusionpact Hero Banner" width="350"/>
</p>

<h1 align="center">🌟 Fusionpact DevOps Gauntlet: Assessment 2026</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Status-Cloud--Ready-brightgreen?style=for-the-badge&logo=googles-cloud&logoColor=white" title="Project Status"/>
  <img src="https://img.shields.io/badge/Container-Docker--Required-blue?style=for-the-badge&logo=docker&logoColor=white" title="Docker"/>
  <img src="https://img.shields.io/badge/CI/CD-Automation--Focus-red?style=for-the-badge&logo=githubactions&logoColor=white" title="CI/CD"/>
  <img src="https://img.shields.io/badge/Observability-Mandatory-yellowgreen?style=for-the-badge&logo=grafana&logoColor=white" title="Monitoring"/>
</p>

---

<h2 align="center">🎯 MISSION BRIEFING: The Challenge</h2>

<p align="center">
Welcome to the <b>Fusionpact DevOps Gauntlet</b>! This is your final opportunity to prove your mastery of modern cloud engineering.<br/>
Your task is to take this two-tier application stack and transform it into a <b>fault-tolerant, observable, and automated production system</b> in the cloud.
</p>

---

<h3 align="center">💻 Application Stack Overview</h3>

<p align="center">

| Component | Technology | Directory | Key Feature |
| :---: | :---: | :---: | :---: |
| 🖼️ **Frontend** | HTML / CSS | `./frontend/` | Internship Landing Page (Requires lightweight serving) |
| ⚡ **Backend** | Python **FastAPI** | `./backend/` | REST API, Data Handling, and **Prometheus `/metrics`** endpoint |

</p>

---

<h2 align="center">🧪 Challenge Structure</h2>

<p align="center">
The assignment is divided into <b>3 levels</b>. Complete all tasks in each level to qualify.
</p>

---

<h3 align="center">🥇 Level 1 – Cloud Deployment (30%)</h3>

**Objective:** Deploy the full stack on a cloud platform of your choice.

**Requirements:**
- Containerize both frontend and backend using Docker.
- Create a `docker-compose.yml` to orchestrate the services.
- Ensure data persistence (volume or external database).
- Deploy the application on a public cloud (AWS, GCP, or Azure).
- Both frontend and backend must be accessible publicly.

**Deliverables:**
- `Dockerfile` for frontend and backend  
- `docker-compose.yml`  
- Screenshot of the deployed application *(Document this in your SOP)*

---

<h3 align="center">🥈 Level 2 – Monitoring & Observability (30%)</h3>

**Objective:** Implement complete observability for the deployed application.

**Requirements:**
- Set up **Prometheus** to scrape backend metrics from `/metrics`.
- Deploy **Grafana** and create dashboards for:
  - Infrastructure metrics: CPU, memory, disk, container usage.
  - Application metrics: request rate, latency, error counts.
- Dashboards must visualize real-time data from the deployed services. *(Document this in your SOP)*

**Deliverables:**
- `prometheus.yml` configuration file  
- Screenshots of Grafana dashboards (Infrastructure + Application) *(in SOP)*

---

<h3 align="center">🥉 Level 3 – CI/CD Automation (30%)</h3>

**Objective:** Automate the build and deployment workflow.

**Requirements:**
- Implement a CI/CD pipeline using **Jenkins**, **GitHub Actions**, or **GitLab CI/CD**.
- The pipeline must include:
  - Code checkout  
  - Build and test  
  - Docker image build and push  
  - Automatic deployment to the cloud

**Deliverables:**
- CI/CD configuration file (`Jenkinsfile` or `.github/workflows/main.yml`)

---

<h3 align="center">📑 Submission Requirements (10%)</h3>

**Instructions:**
- Fork this repository and push your complete solution.
- Provide a **SOP (Standard Operating Procedure)** — **do NOT** push the SOP to GitHub.  
- Submit the SOP **via email**.

**Submission Checklist:**
- ✅ GitHub repository URL  
- ✅ SOP PDF (attached in email)  
- ✅ Submit the Google Form once the tasks are complete

---

<h3 align="center">📊 Evaluation Criteria</h3>

<p align="center">

| Category | Weight |
| :---: | :---: |
| ☁️ Cloud Deployment | 30% |
| 📊 Monitoring & Observability | 30% |
| 🔁 CI/CD Automation | 30% |
| 📄 Documentation & SOP | 10% |

</p>

<p align="center">
  ⚠️ <b>FINAL CHECK:</b> Submissions will be rejected if the deployment is not in the cloud or if the SOP is missing.
</p>

---

<p align="center">
  <img src="https://raw.githubusercontent.com/Fusionpact-Org/assets/main/devops-fun.gif" alt="DevOps Fun GIF" width="400"/>
</p>

<h3 align="center">🚀 SHOW US YOUR BEST WORK</h3>

<p align="center">
Showcase <b>reliability, scalability, and automated cloud deployments</b> like a pro.  
This is your chance to prove you can build real-world, production-ready systems.
</p>
