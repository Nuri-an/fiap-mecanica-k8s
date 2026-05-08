# Automotive Workshop Management System

Integrated Service Management System for Automotive Workshop - Back-end

## Table of Contents

- [Overview](#overview)
- [Phase 2 - Scalability & Infrastructure](#phase-2---scalability--infrastructure)
- [Architecture](#architecture)
- [Technologies](#technologies)
- [Features](#features)
- [Getting Started](#getting-started)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Terraform Provisioning](#terraform-provisioning)
- [CI/CD Pipeline](#cicd-pipeline)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Database](#database)
- [Security](#security)
- [Contributing](#contributing)

## Overview

This project is the back-end for an automotive workshop management system. It enables workshops to manage customers, vehicles, services, parts inventory, and service orders efficiently.

### Key Benefits

- Organized service order management
- Real-time service tracking for customers
- Efficient parts and inventory control
- Complete customer and vehicle history
- Automated budget generation
- Digital approval and rejection flow
- Priority-based service order listing
- Kubernetes-ready with auto-scaling
- Infrastructure as Code with Terraform
- Automated CI/CD pipeline

## Phase 2 - Scalability & Infrastructure

Phase 2 evolves the system for production scalability, automation, and infrastructure maturity:

- **Health Check Endpoint** - `/api/v1/health` for Docker and Kubernetes probes
- **Priority-Ordered Listings** - Service orders sorted by execution priority with finalized exclusion
- **Budget Rejection** - Customers can now reject budgets with reasons
- **Email Notifications** - Webhook-style endpoint for status update notifications
- **Docker Enhancements** - Health checks and restart policies
- **Kubernetes Orchestration** - Full K8s manifests with HPA auto-scaling
- **Terraform IaC** - Infrastructure provisioning with Kind cluster
- **CI/CD Pipeline** - GitHub Actions with test, build, and deploy stages

### Architecture Overview

```mermaid
graph TB
    subgraph "CI/CD Pipeline"
        GH[GitHub Actions]
        GH -->|test| TEST[Unit & E2E Tests]
        GH -->|build| BUILD[Docker Image]
        GH -->|deploy| DEPLOY[Kind Cluster]
    end

    subgraph "Kubernetes Cluster"
        subgraph "fiap-mecanica namespace"
            HPA[HPA 2-5 replicas]
            HPA --> APP1[App Pod 1]
            HPA --> APP2[App Pod 2]
            APP1 --> PG[PostgreSQL]
            APP2 --> PG
            SVC[NodePort :30000] --> APP1
            SVC --> APP2
        end
    end

    CLIENT[Client] -->|HTTP| SVC
    BUILD -->|load image| DEPLOY
```

## Architecture

The project follows **Hexagonal Architecture** (Ports and Adapters) principles:

- **Domain Independence**: Business logic isolated from external concerns
- **Testability**: Easy to test with mocked dependencies
- **Flexibility**: Easy to swap implementations (e.g., database, external services)
- **Maintainability**: Clear separation of concerns

### Architecture Layers

```
src/
├── domain/              # Business logic and entities (Core)
│   ├── entities/        # Domain entities
│   └── value-objects/   # Value objects (CPF, Email, etc.)
├── application/         # Use cases and ports (Application)
│   ├── ports/           # Repository and service interfaces
│   └── use-cases/       # Business use cases
├── infrastructure/      # External adapters (Infrastructure)
│   ├── database/        # Prisma client
│   ├── repositories/    # Repository implementations
│   ├── notifications/   # Notification service implementations
│   └── auth/            # Authentication
├── presentation/        # API layer (Presentation)
│   ├── controllers/     # REST controllers
│   └── dtos/            # Data transfer objects
└── modules/             # NestJS modules
```

### C4 Architecture Documentation

Comprehensive architecture diagrams are available in PlantUML format (`.wsd` files) following the C4 model:

**[docs/](docs/)** - See [docs/README.md](docs/README.md) for viewing instructions

1. **[Context Diagram](docs/c4-context.wsd)** - System context with actors and external systems
2. **[Container Diagram](docs/c4-container.wsd)** - High-level technology choices (API, Database, Swagger)
3. **[Component Diagram](docs/c4-component.wsd)** - Detailed hexagonal architecture components
4. **[Deployment Diagram](docs/c4-deployment.wsd)** - Development and production environments

## Technologies

- **Node.js** 20+ - Runtime environment
- **NestJS** 10+ - Progressive Node.js framework
- **TypeScript** 5+ - Type-safe JavaScript
- **Prisma ORM** 5+ - Next-generation ORM
- **PostgreSQL** 16+ - Relational database
- **JWT** - Authentication
- **Swagger** - API documentation
- **Jest** - Testing framework
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Terraform** - Infrastructure as Code
- **Kind** - Local Kubernetes clusters
- **GitHub Actions** - CI/CD pipeline

## Features

### Customer Management
- CRUD operations for customers
- CPF/CNPJ validation
- Customer search and filtering
- Soft delete support

### Vehicle Management
- CRUD operations for vehicles
- License plate validation (Brazilian format)
- Vehicle history tracking
- Customer-vehicle relationship

### Service Catalog
- Service management
- Category classification
- Price and duration estimation
- Active/inactive status

### Parts & Inventory
- Parts catalog management
- Stock control
- Low stock alerts
- Stock movement history

### Service Orders (OS)
- Complete service order lifecycle
- Priority-based listing (In Progress > Awaiting Approval > In Diagnosis > Received)
- Finalized order exclusion by default
- Budget approval and rejection with reasons
- Email notification webhook for status updates
- Multiple status tracking:
  - Received > In Diagnosis > Awaiting Approval > Approved > In Progress > Completed > Delivered
  - Awaiting Parts (from In Progress or Approved)
  - Cancelled (from most statuses)
- Service and parts association
- Status history tracking
- Average execution time monitoring

### Security
- JWT-based authentication
- Protected administrative endpoints
- Public endpoints for customer tracking and approval
- Password encryption with bcrypt

## Getting Started

### Prerequisites

- Node.js 20+ installed
- Docker and Docker Compose installed
- Git

### Quick Setup (Recommended)

```bash
chmod +x run.sh
./run.sh
```

### Manual Installation

1. **Clone the repository**

```bash
git clone https://github.com/JulioRios00/FiapMecanica
cd FiapMecanica
```

2. **Install dependencies**

```bash
npm install
```

3. **Set up environment variables**

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL="postgresql://workshop:workshop123@localhost:5432/workshop_db?schema=public"
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION=24h
API_PREFIX=api/v1
```

4. **Start the database with Docker**

```bash
docker-compose up -d postgres
```

5. **Run database migrations**

```bash
npm run prisma:generate
npm run prisma:migrate
```

6. **Seed the database (optional)**

```bash
npm run prisma:seed
```

7. **Start the application**

```bash
# Development mode
npm run start:dev

# Production mode
npm run build
npm run start:prod
```

### Using Docker Compose

Start the entire application stack (database + API):

```bash
docker-compose up -d
```

This will:
- Start PostgreSQL database on port 5432
- Run migrations automatically
- Start the API on port 3000 with health checks

### Accessing the Application

- **API Base URL**: http://localhost:3000/api/v1
- **Swagger Documentation**: http://localhost:3000/api/docs
- **Health Check**: http://localhost:3000/api/v1/health

## Kubernetes Deployment

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [Kind](https://kind.sigs.k8s.io/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed

### Deploy with Kind + kubectl

1. **Build the Docker image**

```bash
docker build -t fiap-mecanica:latest .
```

2. **Create a Kind cluster**

```bash
cat <<EOF | kind create cluster --name fiap-mecanica-cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
    - containerPort: 80
      hostPort: 80
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      protocol: TCP
- role: worker
EOF
```

3. **Load the image into Kind**

```bash
kind load docker-image fiap-mecanica:latest --name fiap-mecanica-cluster
```

4. **Apply Kubernetes manifests**

- **Install ingress controller**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

- **Install metrics service**
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

- **Apply all**
```bash
kubectl apply -k k8s/
```

5. **Verify deployment**

```bash
kubectl get pods -n fiap-mecanica
kubectl get svc -n fiap-mecanica
kubectl get hpa -n fiap-mecanica
```

6. **Access the application**

- **For win / WSL port mapping**
```bash
kubectl port-forward -n fiap-mecanica svc/fiap-mecanica-service 3000:80 --address 0.0.0.0
```

- **API**: http://localhost:30000/api/v1
- **Swagger**: http://localhost:30000/api/docs
- **Health**: http://localhost:30000/api/v1/health

### Kubernetes Resources

| Resource | Description |
|----------|-------------|
| Namespace | `fiap-mecanica` |
| ConfigMap | Non-secret configuration |
| Secret | JWT secret, DB credentials |
| PVC | 1Gi PostgreSQL storage |
| PostgreSQL Deployment | 1 replica with liveness/readiness probes |
| App Deployment | 2 replicas with init container for migrations |
| PostgreSQL Service | ClusterIP on port 5432 |
| App Service | NodePort on port 30000 |
| HPA | Auto-scale 2-5 replicas (CPU 70%, Memory 80%) |

## Terraform Provisioning

Terraform automates the entire Kubernetes cluster and deployment setup.

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0.0
- Docker image `fiap-mecanica:latest` built locally

### Provision Infrastructure

```bash
cd infra

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply

# Destroy when done
terraform destroy
```

See [infra/README.md](infra/README.md) for detailed instructions.

## CI/CD Pipeline

The project uses GitHub Actions with three stages:

### Pipeline Stages

1. **Test** (on push to main/develop, PRs to main)
   - Spins up PostgreSQL service container
   - Installs dependencies and generates Prisma client
   - Runs database migrations
   - Builds the application
   - Executes unit tests and E2E tests

2. **Build Image** (on push to main only, after tests pass)
   - Sets up Docker Buildx
   - Builds `fiap-mecanica:latest` image
   - Saves as artifact for deploy stage

3. **Deploy** (on push to main only, after build)
   - Creates Kind cluster
   - Loads Docker image into Kind
   - Applies all Kubernetes manifests
   - Waits for rollout with timeout
   - Verifies deployment status

### Trigger Conditions

| Event | Test | Build | Deploy |
|-------|------|-------|--------|
| Push to `main` | Yes | Yes | Yes |
| Push to `develop` | Yes | No | No |
| PR to `main` | Yes | No | No |

## API Documentation

### Interactive Documentation

Access Swagger UI at: http://localhost:3000/api/docs

### Main Endpoints

#### Health
- `GET /api/v1/health` - Health check (public)

#### Customers
- `POST /api/v1/customers` - Create customer
- `GET /api/v1/customers` - List customers
- `GET /api/v1/customers/:id` - Get customer by ID
- `PUT /api/v1/customers/:id` - Update customer
- `DELETE /api/v1/customers/:id` - Delete customer

#### Service Orders
- `POST /api/v1/service-orders` - Create service order
- `GET /api/v1/service-orders` - List service orders (priority-sorted, excludes finalized)
- `GET /api/v1/service-orders/:id` - Get service order (public)
- `PUT /api/v1/service-orders/:id/status` - Update status
- `POST /api/v1/service-orders/:id/approve` - Approve or reject order (public)
- `POST /api/v1/service-orders/notify/status-update` - Status update via notification (public webhook)
- `GET /api/v1/service-orders/metrics/execution` - Execution metrics

### Postman Collection

A comprehensive Postman collection is available:

```bash
npm install -g newman
newman run FiapMecanica.postman_collection.json \
  --env-var "baseUrl=http://localhost:3000/api/v1"
```

## Testing

### Unit & Integration Tests

```bash
# Run unit tests
npm test

# Run with coverage
npm run test:cov

# Run E2E tests
npm run test:e2e
```

### Coverage Requirements

The project aims for **80% minimum coverage** on critical domains:

- Domain entities
- Value objects
- Use cases
- Repository implementations

## Project Structure

```
FiapMecanica/
├── .github/workflows/           # CI/CD pipeline
│   └── ci-cd.yml               # GitHub Actions workflow
├── docs/                        # Architecture documentation (C4)
├── infra/                       # Terraform infrastructure
│   ├── main.tf                 # Provider configuration
│   ├── variables.tf            # Input variables
│   ├── kind-cluster.tf         # Kind cluster resource
│   ├── kubernetes.tf           # K8s provider and resources
│   ├── outputs.tf              # Output values
│   ├── terraform.tfvars        # Default values
│   └── README.md               # Terraform instructions
├── k8s/                         # Kubernetes manifests
│   ├── namespace.yaml          # Namespace
│   ├── configmap.yaml          # ConfigMap
│   ├── secret.yaml             # Secrets
│   ├── postgres-pvc.yaml       # PostgreSQL PVC
│   ├── postgres-deployment.yaml # PostgreSQL Deployment
│   ├── postgres-service.yaml   # PostgreSQL Service
│   ├── app-deployment.yaml     # App Deployment
│   ├── app-service.yaml        # App Service (NodePort)
│   └── hpa.yaml                # Horizontal Pod Autoscaler
├── prisma/                      # Database schema and migrations
├── src/
│   ├── application/             # Use cases and ports
│   ├── domain/                  # Business entities and value objects
│   ├── infrastructure/          # Repositories, auth, notifications
│   ├── presentation/            # Controllers and DTOs
│   ├── modules/                 # NestJS modules
│   ├── shared/                  # Shared utilities
│   ├── app.module.ts            # Root module
│   └── main.ts                  # Entry point
├── test/                        # E2E tests
├── Dockerfile                   # Multi-stage Docker build with healthcheck
├── docker-compose.yml           # Docker composition
├── package.json                 # Dependencies
└── README.md                    # This file
```

## Database

### Entity Relationship

```
Customer (1) ──── (*) Vehicle
    │                   │
    │                   │
    └─────── (*) ServiceOrder (*) ───────┐
                    │                     │
                    │                     │
                (*) ServiceOrderItem   (*) PartOrderItem
                    │                     │
                    │                     │
                Service                 Part
```

### Key Tables

- **customers**: Customer information
- **vehicles**: Vehicle registry
- **services**: Service catalog
- **parts**: Parts inventory
- **service_orders**: Service orders
- **service_order_items**: Services in order
- **part_order_items**: Parts in order
- **service_order_status_history**: Status tracking
- **users**: System users

## Security

### Implemented Security Measures

1. **Authentication**: JWT-based authentication
2. **Password Hashing**: bcrypt with salt rounds
3. **Input Validation**: class-validator for DTOs
4. **Document Validation**: CPF/CNPJ validation algorithms
5. **License Plate Validation**: Brazilian format validation
6. **Protected Endpoints**: JWT guard for admin operations
7. **Public Endpoints**: Service order tracking and approval for customers
8. **K8s Secrets**: Sensitive data stored in Kubernetes Secrets

### Environment Variables

Never commit sensitive data:

- Keep `.env` file out of version control
- Use strong JWT secrets in production
- Rotate secrets regularly
- Use environment-specific configurations

## Contributing

### Development Workflow

1. Create a feature branch
2. Implement changes
3. Write/update tests
4. Run linter: `npm run lint`
5. Run tests: `npm test`
6. Commit with descriptive messages
7. Create pull request

### Code Style

The project uses:

- **ESLint** for linting
- **Prettier** for formatting

```bash
npm run format
npm run lint
```

## License

This project is part of FIAP Tech Challenge and is for educational purposes.

## Authors

FIAP Tech Challenge Team

---

**Built with NestJS, Hexagonal Architecture, Kubernetes, and Terraform**
