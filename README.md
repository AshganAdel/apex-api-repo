
# Apex Operations API

Designed and deployed a cloud-native REST API using FastAPI and Python, backed by Amazon RDS PostgreSQL and hosted on a private Amazon EKS cluster. Provisioned AWS infrastructure using Terraform and implemented a CI/CD workflow using GitHub Actions and Argo CD. The project incorporates automated testing, security scanning, secure secrets management, GitOps-based deployments, and end-to-end monitoring using Prometheus and Grafana.

The following diagram illustrates the overall architecture of the Apex API project, covering AWS infrastructure, CI/CD automation, Kubernetes deployment, security, and monitoring.

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1HSPAiDnIjvbZFmLVol8fCzQG-XZFTird" alt="Apex API Architecture" width="100%">
</p>
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

```
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

## Application Features

### REST API

The application provides a RESTful API built with FastAPI and Python, backed by PostgreSQL on Amazon RDS.

Supported operations include:

- Retrieve all items.
- Retrieve an item by ID.
- Update an existing item.
- Check application health and readiness.
- Expose application metrics for Prometheus monitoring.

### Health and Readiness Checks

The application provides dedicated endpoints for Kubernetes health monitoring.

**Health Check**
```http
GET /health
```
Verifies that the application is running.

**Readiness Check**
```http
GET /ready
```
Verifies that the application is ready to serve requests, including database connectivity.

**Prometheus Metrics**
```http
GET /metrics
```
Exposes application metrics for Prometheus collection.

---

## Infrastructure Provisioning

AWS infrastructure is provisioned using Terraform (Infrastructure as Code).

The infrastructure includes:

- Amazon VPC with public and private networking.
- Amazon EKS cluster with private worker nodes.
- Three worker nodes distributed across three Availability Zones.
- Amazon RDS PostgreSQL for persistent database storage.
- AWS IAM roles and policies for secure service access.
- AWS Secrets Manager for database credentials management.

---

## Getting Started

### Prerequisites

Make sure you have the following tools installed:

- Git
- Docker
- Python 3.12
- Terraform
- AWS CLI
- kubectl
- Helm

### Clone the Repository

```bash
git clone https://github.com/AshganAdel/apex-api-repo.git

cd apex-api-repo
```

---

## Infrastructure Deployment

Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Review the infrastructure changes:

```bash
terraform plan
```

Provision the AWS infrastructure:

```bash
terraform apply
```

---

## Environment Configuration

The application uses Kubernetes ConfigMaps for non-sensitive configuration and AWS Secrets Manager for sensitive database credentials.

### ConfigMap

The `configmap.yml` file contains database connection settings:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: apex-api-config
data:
  DB_HOST: "your-rds-endpoint"
  DB_PORT: "5432"
  DB_NAME: "appdb"
```

### Secrets Management

Database credentials are securely stored in AWS Secrets Manager.

The application retrieves these credentials through:

- EKS Pod Identity for IAM authentication.
- AWS Secrets Manager for secure credential storage.
- Secrets Store CSI Driver for mounting secrets into application pods.
- SecretProviderClass for defining the secret retrieval configuration.

**Important:** Never store database passwords or other sensitive credentials directly in Kubernetes ConfigMaps or Git repositories.

---

## Kubernetes Deployment

The application runs on a private Amazon EKS cluster.

Kubernetes manifests are maintained in the `k8s/` directory.

### Kubernetes Resources

| Resource | Purpose |
|---|---|
| Deployment | Manages application pods and replicas. |
| Service | Provides internal network access to the application. |
| ConfigMap | Stores non-sensitive application configuration. |
| SecretProviderClass | Integrates AWS Secrets Manager with Kubernetes. |
| HPA | Automatically scales application pods based on resource utilization. |
| ServiceMonitor | Configures Prometheus scraping for application metrics. |
| Ingress | Configures external access to selected cluster services. |

### Application Deployment with Argo CD

Argo CD continuously monitors the Git repository containing Kubernetes manifests and synchronizes the desired application state with the EKS cluster.

This implements a GitOps-based deployment workflow.

### Horizontal Pod Autoscaling

The application uses Kubernetes Horizontal Pod Autoscaler (HPA) to automatically adjust the number of application replicas based on resource utilization.

This helps the application handle changing workloads without manually scaling pods.

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/operations` | Retrieve all operations. |
| GET | `/operations/{operation_id}` | Retrieve an operation by ID. |
| PUT | `/operations/{operation_id}` | Update an existing operation. |
| GET | `/health` | Application health check. |
| GET | `/ready` | Application readiness check. |
| GET | `/metrics` | Expose Prometheus application metrics. |

Interactive API documentation:

```text
http://localhost:8000/docs
```

---

## CI Pipeline

GitHub Actions automates the Continuous Integration workflow whenever code is pushed to the `main` branch.

The pipeline includes:

1. **Code Checkout:** Retrieves the latest source code.
2. **Python Setup:** Configures Python 3.12.
3. **Code Quality:** Runs Ruff to identify code quality issues.
4. **Dependency Installation:** Installs application dependencies.
5. **Dependency Security Scanning:** Uses pip-audit to identify vulnerable Python packages.
6. **Automated Testing:** Executes Pytest against a PostgreSQL 16 service.
7. **Docker Build:** Builds a versioned application image.
8. **Container Security Scanning:** Uses Trivy to scan the Docker image for HIGH and CRITICAL vulnerabilities.
9. **Artifact Upload:** Uploads test results and security reports.
10. **Image Publishing:** Pushes the validated Docker image to Docker Hub.

### Pipeline Security Gates

The pipeline is configured to fail when required validation or security scanning steps fail.

Trivy is configured with `exit-code: 1` for HIGH and CRITICAL vulnerabilities, preventing images with matching findings from proceeding to the publishing stage.

---

## Security

Security practices implemented in this project include:

- Running the application as a non-root user.
- Using a lightweight Python base image.
- Managing non-sensitive configuration through Kubernetes ConfigMaps.
- Storing database credentials in AWS Secrets Manager.
- Using EKS Pod Identity for secure AWS service authentication.
- Integrating Secrets Store CSI Driver for secret delivery to application pods.
- Scanning Python dependencies using pip-audit.
- Scanning Docker images using Trivy.
- Integrating security checks into the CI pipeline.

---

## Monitoring and Observability

Prometheus and Grafana provide monitoring and observability for both the application and Kubernetes cluster.

### Application Monitoring

The application exposes a `/metrics` endpoint that allows Prometheus to collect application-level metrics.

A Kubernetes ServiceMonitor is configured to enable Prometheus metric discovery and scraping.

### Kubernetes Monitoring

Prometheus collects cluster-related metrics to help monitor:

- Pod resource utilization.
- CPU and memory usage.
- Kubernetes workload health.
- Application availability and performance.

### Grafana Dashboards

Grafana provides dashboards for visualizing application and Kubernetes metrics.

These dashboards help identify performance issues, monitor resource consumption, and observe application behavior.

---

## Application Access

AWS Application Load Balancer (ALB) is integrated with Kubernetes Ingress to provide external access to selected cluster services.

Ingress resources are configured for:

- Argo CD dashboard.
- Grafana monitoring dashboard.

The application itself runs on private EKS worker nodes, while its database is hosted on Amazon RDS.

---

## Deployment and Rollback

### CI Image Versioning

Docker images are tagged using the GitHub Actions run number.

Example:

```text
ashganadel/apex-api:25
ashganadel/apex-api:26
ashganadel/apex-api:27
```

### Deployment

GitHub Actions builds and publishes the application image to Docker Hub.

Argo CD monitors the Kubernetes manifests repository and synchronizes the desired deployment configuration with the EKS cluster.

The image tag is managed through the Kubernetes Deployment manifest.

### Rollback

If a new application version introduces issues:

1. Update the image tag in the Kubernetes Deployment manifest to the previous stable version.
2. Commit and push the change to Git.
3. Allow Argo CD to synchronize the updated manifest.
4. Verify application recovery through health checks and monitoring dashboards.

This follows a GitOps-based rollback approach.

---

## Testing

Automated application tests are implemented using Pytest.

Run the test suite locally:

```bash
pytest -v
```

Run code quality checks:

```bash
ruff check . --ignore B008
```

The test suite validates application behavior, including:

- Health endpoint.
- Readiness endpoint.
- API functionality.
- Request validation.
- Expected HTTP responses.

GitHub Actions executes these tests as part of the CI pipeline.

---

## Project Objective

This project demonstrates an end-to-end DevOps workflow for building, provisioning, securing, deploying, and monitoring a cloud-native application on AWS.

It combines Infrastructure as Code, automated CI pipelines, DevSecOps practices, Kubernetes orchestration, GitOps-based deployments, secure secrets management, auto-scaling, and observability to deliver a reliable and maintainable application environment.
