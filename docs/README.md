# C4 Model Documentation - FiapMecanica

This directory contains C4 model diagrams for the Automotive Workshop Management System, created using PlantUML.

## Overview

The C4 model provides a hierarchical set of software architecture diagrams for different stakeholders:

1. **Context** - Shows the system in its environment
2. **Container** - Shows the high-level technology choices
3. **Component** - Shows the components within containers
4. **Deployment** - Shows how containers are deployed

## Diagrams

### 1. System Context Diagram
**File**: `c4-context.wsd`

**Purpose**: Shows the big picture - how the Workshop Management System fits into the world.

**Audience**: Everyone (technical and non-technical)

**Key Elements**:
- Customers tracking service orders
- Workshop employees managing operations
- System administrators
- External email and payment systems

---

### 2. Container Diagram
**File**: `c4-container.wsd`

**Purpose**: Shows the high-level technology choices and how containers communicate.

**Audience**: Technical people inside and outside the development team

**Key Containers**:
- **API Application** (NestJS, TypeScript) - Backend REST API
- **Database** (PostgreSQL 16+) - Data persistence
- **Swagger UI** - API documentation and testing
- **Web Application** (Future) - Frontend interface

---

### 3. Component Diagram
**File**: `c4-component.wsd`

**Purpose**: Shows the components within the API Application following Hexagonal Architecture.

**Audience**: Software architects and developers

**Key Components**:

#### Presentation Layer
- REST Controllers (CustomerController, VehicleController, etc.)
- DTOs for validation
- Auth Guards for security

#### Application Layer
- Use Cases (CreateCustomer, CreateServiceOrder, etc.)
- Business logic orchestration

#### Domain Layer (Core)
- Entities (Customer, Vehicle, ServiceOrder, etc.)
- Value Objects (CPF, Email, LicensePlate)
- Business rules

#### Infrastructure Layer
- Repository Implementations
- Prisma ORM
- Database access

---

### 4. Deployment Diagram
**File**: `c4-deployment.wsd`

**Purpose**: Shows how containers are deployed in development and production environments.

**Audience**: DevOps engineers, system administrators

**Environments**:
- **Development**: Docker Compose with local containers
- **Production**: Kubernetes/Cloud with load balancing and managed database

---

## How to View Diagrams

### Option 1: VS Code with PlantUML Extension

1. Install the PlantUML extension
2. Install Java (required for PlantUML)
3. Open any `.wsd` file
4. Press `Alt+D` to preview

### Option 2: Online PlantUML Viewer

1. Go to https://www.plantuml.com/plantuml/uml/
2. Copy the content of any `.wsd` file
3. Paste and view the diagram

### Option 3: Command Line

```bash
# Install PlantUML
brew install plantuml  # macOS
apt-get install plantuml  # Ubuntu

# Generate PNG images
plantuml docs/c4-context.wsd
plantuml docs/c4-container.wsd
plantuml docs/c4-component.wsd
plantuml docs/c4-deployment.wsd
```

---

## Architecture Highlights

### Hexagonal Architecture (Ports and Adapters)

The system follows hexagonal architecture principles:

- **Domain Layer**: Pure business logic, no external dependencies
- **Application Layer**: Use cases orchestrate domain entities
- **Infrastructure Layer**: Adapters for database, external services
- **Presentation Layer**: REST API controllers, DTOs, guards

### Benefits

✅ **Testability**: Easy to test with mocked dependencies  
✅ **Flexibility**: Easy to swap implementations  
✅ **Maintainability**: Clear separation of concerns  
✅ **Domain Independence**: Business logic isolated from framework

---

## Technology Stack

- **Runtime**: Node.js 20+
- **Framework**: NestJS 10+
- **Language**: TypeScript 5+
- **Database**: PostgreSQL 16+
- **ORM**: Prisma 5+
- **Authentication**: JWT
- **Documentation**: Swagger/OpenAPI
- **Testing**: Jest
- **Containerization**: Docker

---

## References

- [C4 Model](https://c4model.com/)
- [PlantUML](https://plantuml.com/)
- [C4-PlantUML](https://github.com/plantuml-stdlib/C4-PlantUML)
- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)

---

**Last Updated**: January 2026  
**Project**: FIAP Tech Challenge - Automotive Workshop Management System
