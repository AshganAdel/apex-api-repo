
# Apex Operations API

Designed and deployed a cloud-native REST API using FastAPI and Python, backed by Amazon RDS PostgreSQL and hosted on a private Amazon EKS cluster. Provisioned AWS infrastructure using Terraform and implemented a CI/CD workflow using GitHub Actions and Argo CD. The project incorporates automated testing, security scanning, secure secrets management, GitOps-based deployments, and end-to-end monitoring using Prometheus and Grafana.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Application Features](#application-features)
- [Getting Started](#getting-started)
- [Environment Configuration](#environment-configuration)
- [Running with Kubernetes](#running-with-docker-compose)
- [API Endpoints](#api-endpoints)
- [CI Pipeline](#ci-pipeline)
- [Security](#security)
- [Monitoring and Logging](#monitoring-and-logging)
- [Deployment and Rollback](#deployment-and-rollback)
- [Testing](#testing)
- [Runbook](#runbook)

---

## Project Overview

Apex Operations API is a small backend service designed to demonstrate how an application can be packaged, tested, deployed, monitored, and maintained using modern DevOps practices.

Key Project Implementations:

- **Infrastructure as Code:** Provisioned AWS infrastructure using Terraform, deploying an Amazon EKS cluster with three worker nodes distributed across three Availability Zones and Amazon RDS PostgreSQL.

- **REST API Development:** Built a RESTful API using FastAPI and Python, supporting item retrieval, item updates, and retrieval by ID, with PostgreSQL for persistent data storage.

- **CI Pipeline Automation:** Implemented a GitHub Actions pipeline to automate code linting, dependency installation, application testing, and Docker image building.

- **DevSecOps Integration:** Integrated pip-audit for Python dependency vulnerability scanning and Trivy for Docker image security scanning, enforcing security checks before publishing images.

- **Containerization:** Built and published versioned Docker images to Docker Hub as part of the automated CI workflow.

- **Kubernetes Deployment:** Deployed the application on a private Amazon EKS cluster, distributing workloads across three worker nodes in three Availability Zones.

- **GitOps & Continuous Deployment:** Integrated Argo CD with a Git repository containing Kubernetes manifests to automate application deployment and maintain synchronization between Git and the EKS cluster.

- **Secure Secrets Management:** Integrated AWS Secrets Manager with the Secrets Store CSI Driver to securely retrieve and mount database credentials into application pods.

- **AWS Pod Identity:** Configured EKS Pod Identity to grant application pods secure IAM access to AWS Secrets Manager without embedding static AWS credentials.

- **Monitoring & Observability:** Implemented Prometheus and Grafana to collect and visualize application metrics and Kubernetes cluster performance.

- **Application Health Monitoring:** Exposed application health, readiness, and Prometheus metrics endpoints to support health checks and application observability.

- **Application Access & Ingress:** Configured AWS Application Load Balancer (ALB) with Kubernetes Ingress to expose Argo CD and Grafana dashboards.


---

## Architecture

```text
             Developer
                 |
                 v
          GitHub Repository
                 |
                 v
           GitHub Actions
                 |
        +--------+--------+
        |        |        |
      Lint     Tests    Security
        |        |        |
        +--------+--------+
                 |
                 v
           Docker Build
                 |
                 v
            Docker Hub
                 |
                 +
                 |
                 v
    K8s "EKS" ----> AWS postgres RDS
                 |
Deployment, ConfigMap, Services, SecretProviderClass ----> AWS secret manager

---

## Technology Stack

| Category | Technologies |
|---|---|
| **Backend Development** | Python 3.12, FastAPI |
| **Database** | PostgreSQL 16, Amazon RDS |
| **Cloud Platform** | AWS |
| **Infrastructure as Code** | Terraform |
| **Containerization** | Docker, Docker Hub |
| **Container Orchestration** | Kubernetes, Amazon EKS |
| **CI/CD** | GitHub Actions |
| **GitOps & Deployment** | Argo CD |
| **Secrets Management** | AWS Secrets Manager, Secrets Store CSI Driver, EKS Pod Identity |
| **Monitoring & Observability** | Prometheus, Grafana |
| **Networking & Load Balancing** | AWS Application Load Balancer (ALB), Kubernetes Ingress |
| **Auto Scaling** | Kubernetes Horizontal Pod Autoscaler (HPA) |
| **Code Quality & Testing** | Ruff, Pytest |
| **Security Scanning** | pip-audit, Trivy |
| **Version Control** | Git, GitHub |
---

## Project Structure

```text
apex-api/
│
├── src/
│   ├── database.py
│   ├── models.py
│   ├── routes/
│   └── schemas/
├── main.py
|   
├── tests/
│   └── test_main.py
│
├── k8s
|   └── 
├── requirements.txt
├── .dockerignore
├── .gitignore
├── .env.example
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
└── docs/
    └── RUNBOOK.md
```

---

## Application Features

### REST API

The application exposes endpoints to manage operations.

- Retrieve operations.
- Retrieve an operation by ID.
- Update an existing operation.
- Check application health.
- Check application readiness.

### Health and Readiness Checks

The application provides two operational endpoints:

**Health Check**

```http
GET /health
```

Checks whether the application is running.

**Readiness Check**

```http
GET /ready
```

Checks whether the application is ready to serve requests, including database connectivity.

---

## Getting Started

### Prerequisites

Make sure you have the following installed:

- Docker
- Kubernetes 
- Git

### Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>

cd apex-api
```

---

## Environment Configuration

Create a `configMap` file in the project k8s files:

```env
USER_NAME=your_dockerhub_username
IMAGE_TAG=latest

POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DB=apexdb

DATABASE_URL=postgresql://postgres:your_password@db:5432/apexdb
```

**Important:** Never commit real credentials or sensitive environment variables to GitHub.

Use `.env.example` to document the required variables without exposing secrets.

---

## Running with Kubernetes

Start the application and database:

```bash
docker compose up -d
```

Check running containers:

```bash
docker compose ps
```

View application logs:

```bash
docker compose logs -f app
```

Check application health:

```bash
curl http://localhost:8000/health
```

Check readiness:

```bash
curl http://localhost:8000/ready
```

Stop the application:

```bash
docker compose down
```

To stop the application without removing persistent database data, avoid using the `-v` option.

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/operations` | Retrieve all operations |
| GET | `/operations/{operation_id}` | Retrieve an operation by ID |
| PUT | `/operations/{operation_id}` | Update an existing operation |
| GET | `/health` | Application health check |
| GET | `/ready` | Application readiness check |
| GET | `/metrics` | Prometheus metrics |

Interactive API documentation is available at:

```text
http://localhost:8000/docs
```

---

## CI Pipeline

GitHub Actions automates the validation process whenever code is pushed to the repository.

The pipeline includes:

1. Dependency installation.
2. Code quality checks using Ruff.
3. Automated tests using Pytest.
4. Dependency security auditing.
5. Docker image build.
6. Container vulnerability scanning.

### Pipeline Behavior

The workflow is designed to stop when a required validation step fails.

This ensures that an application with failing tests or security-policy violations does not proceed through the successful CI pipeline.

---

## Security

Security practices implemented in this project include:

- Running the application as a non-root user.
- Using a lightweight Python base image.
- Managing configuration through environment variables.
- Avoiding hardcoded credentials.
- Scanning dependencies for known vulnerabilities.
- Scanning Docker images for security vulnerabilities.

---

## Monitoring and Logging

The application provides operational visibility through:

**Structured Logging**

Application logs include:

- Timestamp.
- Log level.
- Request information.
- HTTP response status.
- Request duration.

**Prometheus Metrics**

The `/metrics` endpoint exposes application metrics that can be collected by Prometheus.

These metrics help monitor application behavior and identify potential performance issues.

---

## Deployment and Rollback

Docker images are versioned using unique tags.

Example:

```text
ashganadel/apex-api:25
ashganadel/apex-api:26
ashganadel/apex-api:27
```

### Deployment

Update the image tag in `.env`:

```env
IMAGE_TAG=27
```

Deploy the new version:

```bash
docker compose pull
docker compose up -d
```

### Rollback

If the new version introduces an issue, update the image tag to the previous stable version:

```env
IMAGE_TAG=26
```

Then run:

```bash
docker compose pull
docker compose up -d
```

Verify application recovery:

```bash
docker compose ps
curl http://localhost:8000/health
```

---

## Testing

Automated tests are implemented using Pytest.

Run the test suite locally:

```bash
pytest -v
```

Run code quality checks:

```bash
ruff check .
```

The test suite validates application behavior, including:

- Health endpoint.
- Readiness endpoint.
- API functionality.
- Request validation.
- Expected HTTP responses.

The CI workflow also demonstrates failure handling by introducing an intentional test failure and verifying that the pipeline correctly blocks the unsuccessful run.

---

## Runbook

Operational procedures are documented in:

```text
docs/RUNBOOK.md
```

The runbook covers:

- Application deployment.
- Deployment verification.
- Rollback procedures.
- Incident response.
- Troubleshooting.
- Log investigation.
- Database connectivity issues.

---

## Project Objective

This project demonstrates practical DevOps engineering skills through a reproducible application delivery workflow.

It emphasizes automation, reliability, security, observability, and operational readiness rather than simply running an application inside a container.
