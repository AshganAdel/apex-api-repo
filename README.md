
# Apex Operations API

A containerized REST API demonstrating a reliable and reproducible application delivery workflow, from code commit to deployment and rollback.

The project focuses on practical DevOps practices, including containerization, automated testing, CI pipelines, security checks, persistent storage, application observability, and operational procedures.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Application Features](#application-features)
- [Getting Started](#getting-started)
- [Environment Configuration](#environment-configuration)
- [Running with Docker Compose](#running-with-docker-compose)
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

The solution provides:

- A REST API built with FastAPI.
- PostgreSQL database integration.
- Docker-based application packaging.
- Docker Compose orchestration.
- Automated CI workflow using GitHub Actions.
- Automated application and code-quality checks.
- Container security scanning.
- Structured application logging and Prometheus metrics.
- Versioned Docker images to support rollback.

The primary objective is to demonstrate a reliable path from source code changes to a tested and deployable application.

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
                 v
          Docker Compose
                 |
          +------+------+
          |             |
          v             v
      FastAPI App    PostgreSQL
          |
     +----+-----+
     |          |
     v          v
   Logs     Prometheus
              Metrics
```

---

## Technology Stack

| Category | Technology |
|---|---|
| Programming Language | Python 3.12 |
| Backend Framework | FastAPI |
| Database | PostgreSQL |
| ORM | SQLAlchemy |
| Containerization | Docker |
| Orchestration | Docker Compose |
| CI/CD | GitHub Actions |
| Linting | Ruff |
| Testing | Pytest |
| Security Scanning | Trivy / pip-audit |
| Metrics | Prometheus Client |
| Logging | Python Logging |

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
├── Dockerfile
├── compose.yaml
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
- Docker Compose
- Git

### Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>

cd apex-api
```

---

## Environment Configuration

Create a `.env` file in the project root:

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

## Running with Docker Compose

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
