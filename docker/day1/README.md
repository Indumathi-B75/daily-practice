Docker Day 1
Topics practiced
Docker images
Docker containers
Dockerfile
Docker CLI
Container lifecycle
Docker logs
docker exec
docker inspect
Flask containerization
Port publishing
Container debugging
Commands practiced
docker pull
docker images
docker build
docker run
docker ps
docker ps -a
docker stop
docker start
docker restart
docker rm
docker logs
docker exec
docker inspect
What I built

Containerized a basic Flask application using:

app.py
requirements.txt
Dockerfile

The Flask application listens on:

0.0.0.0:5000
Debugging practice

### Problem 1 — Container startup failure

**Symptom:**

The container starts but exits immediately.

**Investigation:**

```bash
docker ps -a
docker logs <container>
docker inspect <container>
```
Root cause:

[The COPY path in the Dockerfile was incorrect, so /app/app.py was not present inside the container. When Docker tried to execute the application, the required file could not be found.]

Fix:

[Correct the COPY instruction so that app.py is copied into the /app directory, then rebuild the image and run the container again.]

Failure 2 — Port/network failure

Symptom:

Container is running but application cannot be reached

Investigation:

[docker ps
docker logs <container>
docker inspect <container>
curl http://localhost:5000]

Root cause:

[The Flask application was bound to 127.0.0.1 inside the container. In a container, 127.0.0.1 refers to the container's own network namespace, so the application was not accepting connections from outside the container.]

Fix:

[Configure Flask to listen on 0.0.0.0:5000, then rebuild and restart the container with port publishing:
docker run -p 5000:5000 <image>]

Mental models
Dockerfile
    ↓
docker build
    ↓
Image
    ↓
docker run
    ↓
Container

Image:

Read-only image layers
        +
Writable container layer
        =
Container filesystem
What I still need to practice
Docker Compose
Docker networking
Volumes
Health checks
Layer caching
Multi-stage builds
Container security
Registry workflow
