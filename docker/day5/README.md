# Docker Day 5 — Security and Image Publishing

## Topics Practiced

```text
Docker
│
├── Docker Hub
│   ├── docker login
│   ├── image tagging
│   ├── semantic versioning
│   └── docker push
│
├── Container Hardening
│   ├── read-only root filesystem
│   ├── tmpfs temporary storage
│   └── non-root execution
│
└── Docker Scout
    ├── image vulnerability scanning
    ├── CVE inspection
    └── upgrade recommendations
```

## 1. Docker Hub Publishing

Image used:

```text
day9-secure:1.0
```

Registry tag format:

```text
indumathi772/day9-secure:1.0.0
```

Commands practiced:

```bash
docker login
docker image ls
docker tag day9-secure:1.0 indumathi772/day9-secure:1.0.0
docker push indumathi772/day9-secure:1.0.0
```

**Verification:** Record whether login and push succeeded.

## 2. Container Hardening

### Read-only root filesystem

```bash
docker inspect day9-secure \
  --format 'Read-only: {{.HostConfig.ReadonlyRootfs}}'
```

Expected:

```text
Read-only: true
```

### Temporary writable storage

```bash
docker inspect day9-secure \
  --format 'Tmpfs: {{json .HostConfig.Tmpfs}}'
```

Verify that `/tmp` is configured as temporary storage.

### Non-root execution

```bash
docker exec day9-secure id
```

Expected: the process runs as UID `10001`, not UID `0`.

## 3. Docker Scout

Check availability:

```bash
docker scout version
```

Inspect the image:

```bash
docker scout quickview day9-secure:1.0
docker scout cves day9-secure:1.0
docker scout recommendations day9-secure:1.0
```

Review reported vulnerabilities and available remediation recommendations.

A vulnerability scan does not prove that an image is completely secure.

## Completion Checklist

- [ ] Docker Hub login verified
- [ ] Image tagged and pushed successfully
- [ ] Read-only root filesystem verified
- [ ] `/tmp` tmpfs verified
- [ ] Non-root UID verified
- [ ] Docker Scout scan completed and reviewed

## Key Learning

```text
Secure Container Workflow
        │
        ├── Publish versioned images
        ├── Restrict filesystem writes
        ├── Run as a non-root user
        └── Scan image vulnerabilities
```

**Security reminder:** Never publish passwords, API keys, access tokens, or other secrets inside an image or repository.
