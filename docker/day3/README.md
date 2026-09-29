# Docker Day 3

## Topics Practiced

Docker
│
├── Flask → PostgreSQL
│   ├── Flask application
│   ├── PostgreSQL database
│   └── database connection
│
├── Docker Compose
│   ├── compose.yaml
│   ├── services
│   ├── environment
│   ├── ports
│   ├── networks
│   └── volumes
│
├── Compose Service Networking
│   ├── Flask service
│   ├── PostgreSQL service
│   ├── service name: db
│   ├── db:5432
│   └── localhost mistake
│
├── PostgreSQL Healthcheck
│   ├── healthcheck
│   ├── pg_isready
│   ├── PostgreSQL readiness
│   └── service_healthy
│
└── Service Dependency
    ├── depends_on
    ├── startup order
    └── wait for healthy PostgreSQL



##Architecture

Host
 │
 │ localhost:5000
 ↓
Flask Container
 │
 │ Docker Compose Network
 │ db:5432
 ↓
PostgreSQL Container
 │
 ↓
Name Volume


##Compose Concepts Practiced

compose.yaml
    ↓
services
    ├── flask
    └── db
         ↓
      postgres:16-alpine


#Practiced:
Docker Compose services
Environment variables
Port mapping
Docker networks
Named volumes
Service-to-service communication
PostgreSQL healthcheck
pg_isready
depends_on
condition: service_healthy


##Commands Practiced
docker compose config
docker compose up
docker compose up -d
docker compose ps
docker compose logs
docker compose down
docker compose down -v
docker compose exec


##Key Learning

Docker run
    ↓
Individual containers

Docker Compose
    ↓
Multiple related services
    ↓
Shared network
    ↓
Service-name communication
    ↓
Healthchecks
    ↓
Service dependencies
