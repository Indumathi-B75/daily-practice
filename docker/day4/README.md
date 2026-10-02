# Docker Day 4 — Image Optimization

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
├── Docker Image Inspection
│   ├── docker image history
│   └── layer sizes
│
└── Multi-Stage Builds
    ├── build stage
    ├── final stage
    ├── COPY --from
    └── smaller final image
```

## 1. Image Layers

Dockerfile instructions create image layers.

```text
Dockerfile
    ↓
Instructions
    ↓
Image Layers
```

Practiced inspecting image layers with:

```bash
docker image history <image>
```

## 2. Build Cache

Docker reuses unchanged layers during subsequent builds.

### Experiment 1 — Change app.py

```text
WORKDIR /app              → CACHED
COPY requirements.txt     → CACHED
RUN pip install           → CACHED
COPY app.py               → REBUILT
```

Changing only application code did not require reinstalling unchanged dependencies.

### Experiment 2 — Change requirements.txt

```text
COPY requirements.txt     → REBUILT
RUN pip install           → REBUILT
COPY app.py               → REBUILT
```

Changing dependencies invalidated the dependency installation layer.

## 3. Dockerfile Instruction Order

Practiced placing dependency installation before application source code:

```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
```

This allows Docker to reuse the dependency layer when only application code changes.

## 4. .dockerignore

Practiced excluding unnecessary files:

```text
__pycache__/
venv/
.env
secret.txt
```

This reduces the Docker build context and prevents unnecessary files from being sent to the builder.

## 5. No-Cache Build

Practiced:

```bash
docker build --no-cache -t cache-test .
```

`--no-cache` forces Docker to rebuild layers instead of reusing the existing build cache.

## 6. Docker Image History

Practiced:

```bash
docker image history <image>
```

Used image history to inspect:

- Image layers
- Layer sizes
- Dockerfile instructions
- Base image layers

## 7. Multi-Stage Builds

A multi-stage Dockerfile separates the build environment from the final runtime image.

```text
BUILD STAGE
├── compiler
├── development tools
├── source code
└── build dependencies
        │
        ↓
      BUILD
        │
        ↓
FINAL STAGE
├── runtime
├── application
└── only required dependencies
```

The final image does not need to contain all the tools used during the build.

### Basic Structure

```dockerfile
FROM <build-image> AS builder

# Build application
# Install build dependencies
# Generate required output

FROM <runtime-image>

COPY --from=builder <build-output> <final-location>
```

### Key Concept

```text
Build stage
     ↓
Create required artifacts
     ↓
COPY --from=builder
     ↓
Final runtime image
```

The goal is to keep the final image smaller and free from unnecessary build tools.

## Multi-Stage Practice

Created a separate practice project:

```text
docker-day8-multistage/
├── app.py
└── Dockerfile
```

The practice application:

```python
print("Hello from a multi-stage Docker build!")
```

## Key Learning

```text
Docker Image Optimization
│
├── Layer caching
│   └── reuse unchanged layers
│
├── .dockerignore
│   └── reduce build context
│
├── Image history
│   └── inspect layers and sizes
│
└── Multi-stage builds
    └── separate build and runtime environments
```
