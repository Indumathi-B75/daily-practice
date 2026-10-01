# Docker Day 4 — Layer Caching

## Topics Practiced

```text
Docker
│
├── Image Layers
│   ├── Dockerfile instructions
│   ├── image history
│   └── layered filesystem
│
├── Build Cache
│   ├── cached layers
│   ├── cache reuse
│   ├── app.py change
│   └── requirements.txt change
│
├── Dockerfile Instruction Order
│   ├── COPY requirements.txt
│   ├── RUN pip install
│   ├── COPY app.py
│   └── dependency layer reuse
│
├── .dockerignore
│   ├── __pycache__
│   ├── venv
│   ├── .env
│   ├── secret files
│   └── smaller build context
│
├── No-Cache Build
│   ├── --no-cache
│   └── forced layer rebuild
│
└── Docker Image Inspection
    ├── docker image history
    └── layer sizes
```

## Cache Experiment

### Initial Build

Docker reused existing layers:

```text
WORKDIR /app
COPY requirements.txt .
RUN pip install
COPY app.py .
```

### Experiment 1 — Change app.py

Only the application layer was invalidated.

```text
WORKDIR /app              → CACHED
COPY requirements.txt     → CACHED
RUN pip install           → CACHED
COPY app.py               → REBUILT
```

This demonstrated that changing application code does not require reinstalling unchanged dependencies.

### Experiment 2 — Change requirements.txt

Changing the dependency file invalidated the dependency installation layer.

```text
COPY requirements.txt     → REBUILT
RUN pip install           → REBUILT
COPY app.py               → REBUILT
```

This demonstrated why Dockerfile instruction order matters.

## .dockerignore

Practiced excluding unnecessary files from the Docker build context:

```text
__pycache__/
venv/
.env
secret.txt
```

This keeps the build context smaller and prevents unnecessary files from being sent to the Docker builder.

## No-Cache Build

Practiced:

```bash
docker build --no-cache -t cache-test .
```

`--no-cache` forces Docker to rebuild the applicable image layers instead of reusing the existing build cache.

## Image History

Practiced:

```bash
docker image history <image>
```

Used image history to inspect:

- Dockerfile layers
- Layer sizes
- Commands associated with layers
- Base image layers

## Key Learning

```text
Dockerfile
    ↓
Instructions
    ↓
Image Layers
    ↓
Build Cache
    ↓
Unchanged layers → Reused
Changed layer → Rebuilt
```

The order of Dockerfile instructions affects cache efficiency.

Keeping dependency installation before application source code allows Docker to reuse the dependency layer when only application code changes.
