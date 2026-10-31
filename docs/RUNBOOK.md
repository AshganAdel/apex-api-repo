# Apex Operations API - Operational Runbook

## 1. Overview

This document describes the operational procedures required to deploy, verify, troubleshoot, and recover the Apex Operations API.

The application runs using Docker Compose and depends on a PostgreSQL database.

## 2. Prerequisites

Ensure the following tools are installed:

- Docker Engine
- Docker Compose
- Git

Ensure that the required environment variables are configured in the `.env` file.

## 3. Deployment Procedure

### Step 1: Configure Environment Variables

Verify the application configuration:

```bash
cat .env
```

Ensure that the image tag and database connection settings are correct.

### Step 2: Pull the Docker Image

```bash
docker compose pull
```

### Step 3: Start the Application

```bash
docker compose up -d
```

### Step 4: Verify Deployment

Check container status:

```bash
docker compose ps
```

Check application health:

```bash
curl -f http://localhost:8000/health
```

Check readiness:

```bash
curl -f http://localhost:8000/ready
```

## 4. Rollback Procedure

If a new deployment introduces errors or unexpected behavior, roll back to the previous stable image.

### Step 1: Identify the Previous Version

Check the previously deployed Docker image tag.

### Step 2: Update Image Tag

Update `IMAGE_TAG` in `.env`:

```env
IMAGE_TAG=previous-stable-tag
```

### Step 3: Pull the Previous Image

```bash
docker compose pull
```

### Step 4: Restart the Application

```bash
docker compose up -d
```

### Step 5: Verify Recovery

```bash
docker compose ps
curl -f http://localhost:8000/health
curl -f http://localhost:8000/ready
```

Confirm that the application is operating correctly.

## 5. Incident Response

When an application failure or service interruption occurs, follow these steps:

1. Identify the affected service.
2. Check container status.
3. Inspect application and database logs.
4. Identify the root cause.
5. Apply a corrective action or perform a rollback.
6. Verify service recovery.
7. Document the incident and its resolution.

### Useful Diagnostic Commands

Check running containers:

```bash
docker compose ps
```

Inspect application logs:

```bash
docker compose logs --tail=100 app
```

Inspect database logs:

```bash
docker compose logs --tail=100 db
```

Inspect container resource usage:

```bash
docker stats
```

## 6. Troubleshooting

| Issue | Possible Cause | Recommended Action |
|---|---|---|
| Application unavailable | Container stopped | Check container status and restart if appropriate |
| Database connection failed | Incorrect DATABASE_URL | Verify database credentials and hostname |
| Readiness check failed | Database unavailable | Inspect database logs and connectivity |
| Container keeps restarting | Application startup error | Inspect application logs |
| Image pull failed | Invalid image tag or registry issue | Verify Docker Hub repository and image tag |
| Data disappeared | Persistent volume issue | Inspect Docker volumes and database configuration |
| Port already in use | Another process occupies port 8000 | Identify the process or change the host port |

## 7. Logging and Monitoring

Application logs:

```bash
docker compose logs -f app
```

Database logs:

```bash
docker compose logs -f db
```

Prometheus metrics endpoint:

```bash
curl http://localhost:8000/metrics
```

Use application logs and metrics to investigate errors, request failures, and performance issues.

## 8. Database Persistence

The PostgreSQL service uses a persistent Docker volume to retain database data across container restarts and recreations.

Verify available volumes:

```bash
docker volume ls
```

Inspect a database volume:

```bash
docker volume inspect <volume_name>
```

**Warning:** Removing Docker volumes can permanently delete database data. Do not use `docker compose down -v` during normal deployments or rollbacks.

## 9. Security Considerations

- Run the application as a non-root user.
- Never commit `.env` files containing real credentials.
- Use strong database passwords.
- Scan Docker images for known vulnerabilities.
- Avoid exposing the database port publicly.
- Apply least-privilege access principles.

## 10. Recovery Verification Checklist

After resolving an incident or performing a rollback, verify:

- [ ] Application container is running.
- [ ] Database container is running.
- [ ] Health endpoint returns HTTP 200.
- [ ] Readiness endpoint returns HTTP 200.
- [ ] API endpoints respond correctly.
- [ ] Application logs show no critical errors.
- [ ] Database data is preserved.
- [ ] The deployed image tag matches the expected version.

---

**End of Runbook**
