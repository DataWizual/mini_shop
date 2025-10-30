# 🏪 Mini Shop — DevOps Showcase Project

[![CI/CD](https://github.com/DataWizual/mini_shop/actions/workflows/deploy.yml/badge.svg)](https://github.com/DataWizual/mini_shop/actions)
[![Docker Hub](https://img.shields.io/badge/DockerHub-mini__shop-blue?logo=docker)](https://hub.docker.com/repositories/eldordevops)

A containerized **microservice environment** demonstrating a full DevOps pipeline —  
from source code delivery to production-ready deployment with **monitoring and CI/CD automation**.

---

## 🧩 Project Overview

**Mini Shop** is a hands-on DevOps training and demonstration environment  
that simulates a small e-commerce backend running in containers.

**Goal:** Practical study of DevOps workflows in a near-real production setup.  
**Role:** Design and implementation of the entire infrastructure pipeline —  
from code retrieval to deployment and monitoring.

---

## ⚙️ Tech Stack

| Layer | Tools |
|-------|--------|
| OS Environment | Lubuntu, 4 GB RAM |
| Container Platform | Docker 28.5.1, Docker Compose |
| Backend | Python / Flask |
| Databases | PostgreSQL, SQLite |
| CI/CD | GitHub Actions → Docker Hub |
| Monitoring | Prometheus + Grafana |
| Automation | Bash scripts, YAML, Infrastructure-as-Code principles |

---

## 🚀 CI/CD Pipeline

This repository includes a working **continuous integration and delivery pipeline**:

- 🧪 Build and test Docker images on every commit  
- 🏷️ Tag images automatically (`latest`, version, commit hash)  
- 🐳 Push to Docker Hub (`datawizual/mini_shop`)  
- 🔄 Deploy locally or remotely using Docker Compose  

```text
Developer → GitHub → GitHub Actions → Docker Hub → Production
```

Example Docker Hub repository:  
👉 [eldordevops/mini_shop](https://hub.docker.com/repositories/eldordevops)

---

## 🚀 One-Command Deployment

All services in the **mini_shop** stack can be deployed automatically  
with a single command using the provided script `deploy_all.sh`.

```bash
./deploy_all.sh
```

This script performs a full end-to-end launch sequence:

1. Builds and starts backend, database, and monitoring containers  
2. Pulls necessary images (or builds them locally if missing)  
3. Initializes databases and configuration files  
4. Brings up Prometheus and Grafana for observability  

After execution, the full environment becomes available:

- 🧩 **Backend (Flask)** — http://localhost:8000  
- 🗄️ **PostgreSQL / SQLite** — internal containers  
- 📊 **Grafana** — http://localhost:3000 (login: `admin / admin`)  
- ⚙️ **Prometheus** — http://localhost:9090  

To reset or stop everything cleanly, use:

```bash
./reset_mini_shop.sh
```

---

## ⚙️ Why One-Command Automation Matters

This design follows the **DevOps reproducibility principle** —  
any environment can be rebuilt from scratch in a predictable, controlled way.

It’s especially valuable for:
- quick onboarding of new developers,  
- CI/CD environment replication,  
- testing disaster recovery and infrastructure automation.

---

## 📊 Monitoring & Observability

Integrated monitoring stack provides visibility into application and system health.

### Metrics Collected
- Container & host metrics (CPU, RAM, I/O, network)
- Backend service metrics (Flask app)
- Database statistics (Postgres exporter)

### Grafana Dashboards
Uses proven **community dashboards** for fast deployment and reliability.  
Custom panels are added only for **critical business metrics**.

Access Grafana locally:  
[http://localhost:3000](http://localhost:3000) — `admin / admin`

---

## 🧠 Architecture Overview

```
┌──────────────┐        ┌──────────────┐
│  GitHub Repo │        │  GitHub CI   │
│   Source     │ ───▶   │  Actions     │
└──────┬───────┘        └──────┬───────┘
       │ build & tag           │ push images
       ▼                       ▼
┌──────────────┐        ┌────────────────┐
│ Docker  Hub  │◀──────▶│ mini_shop env  │
└──────────────┘        │  ├─ Flask API  │
                        │  ├─ Postgres   │
                        │  └─ Monitoring │
                        │     (Prom+Graf)│
                        └────────────────┘
```

---

## 🤖 AI Collaboration

Developed collaboratively with **AI assistant (ChatGPT)** —  
used for architecture design, workflow automation, and troubleshooting.  
Demonstrates practical synergy between **human engineering judgment**  
and **AI-driven development support**.

---

## 🧩 Lessons Learned

- ✅ How to build a full DevOps pipeline from scratch  
- ✅ Integration of CI/CD with Docker Hub  
- ✅ Practical observability using Prometheus + Grafana  
- ✅ Efficient automation on a minimal local setup  

---

## 🧑‍💻 Author

**Eldorz Zufarov (DataWizual)**  
DevOps Engineer · Automation Enthusiast  
[GitHub Profile](https://github.com/DataWizual)

---

## ⚖️ License
MIT License  

> “Automation is not about replacing people —  
> it’s about freeing them to create.” — Eldorz Zufarov  
