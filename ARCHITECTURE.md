# 🏗️ Architecture Documentation

## Hexagonal Architecture (Ports and Adapters)

This project implements Hexagonal Architecture, also known as Ports and Adapters pattern, to achieve a clean separation of concerns and high testability.

## Architecture Overview

```
┌───────────────────────────────────────────────────────────┐
│                     Presentation Layer                    │
│                   (Controllers, DTOs)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Customer   │  │Service Order │  │     Auth     │     │
│  │  Controller  │  │  Controller  │  │  Controller  │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼───────────┘
          │                  │                  │
          │   HTTP/REST      │                  │
          ▼                  ▼                  ▼
┌───────────────────────────────────────────────────────────┐
│                    Application Layer                      │
│                 (Use Cases, Ports/Interfaces)             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Create     │  │   Update     │  │   List       │     │
│  │  Customer    │  │   Status     │  │  Orders      │     │
│  │  Use Case    │  │  Use Case    │  │  Use Case    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼───────────┘
          │                  │                  │
          │   Ports          │                  │
          ▼                  ▼                  ▼
┌───────────────────────────────────────────────────────────┐
│                       Domain Layer                        │
│                  (Business Logic, Entities)               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Customer   │  │Service Order │  │   Vehicle    │     │
│  │   Entity     │  │   Entity     │  │   Entity     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Document    │  │    Email     │  │License Plate │     │
│  │Value Object  │  │Value Object  │  │Value Object  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└───────────────────────────────────────────────────────────┘
          ▲                  ▲                  ▲
          │   Adapters       │                  │
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼─────────────┐
│         │         Infrastructure Layer        │             │
│         │       (Adapters, External Services) │             │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐       │
│  │   Customer   │  │Service Order │  │     Auth     │       │
│  │  Repository  │  │  Repository  │  │   Service    │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
     ┌────────────────────────────────────────────┐
     │           PostgreSQL Database              │
     └────────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Domain Layer (Core)

**Location**: `src/domain/`

The innermost layer containing pure business logic, independent of any framework or external library.

#### Entities
Business objects with identity and lifecycle:
- `Customer`: Customer management
- `Vehicle`: Vehicle information
- `Service`: Service catalog
- `Part`: Parts inventory
- `ServiceOrder`: Service order lifecycle

**Rules**:
- No dependencies on outer layers
- No framework imports
- Pure business logic
- Immutable where possible

#### Value Objects
Objects defined by their attributes rather than identity:
- `Document`: CPF/CNPJ validation
- `Email`: Email validation
- `LicensePlate`: Brazilian license plate validation

**Characteristics**:
- Immutable
- Self-validating
- No identity
- Can be shared

### 2. Application Layer

**Location**: `src/application/`

Orchestrates the flow of data between domain and infrastructure layers.

#### Use Cases
Each use case represents a single business operation:
- `CreateCustomerUseCase`
- `CreateServiceOrderUseCase`
- `UpdateServiceOrderStatusUseCase`
- `ApproveServiceOrderUseCase`

**Rules**:
- One use case per business operation
- Coordinates between repositories
- Validates business rules
- Returns domain entities

#### Ports (Interfaces)
Define contracts for external dependencies:
- `CustomerRepositoryPort`
- `VehicleRepositoryPort`
- `ServiceOrderRepositoryPort`

**Benefits**:
- Dependency inversion
- Easy mocking for tests
- Swappable implementations

### 3. Infrastructure Layer

**Location**: `src/infrastructure/`

Implements the ports defined in the application layer using concrete technologies.

#### Adapters
Concrete implementations of ports:
- `CustomerRepository`: Prisma implementation
- `ServiceOrderRepository`: Prisma implementation
- `AuthService`: JWT authentication

#### Database
- Prisma ORM client
- Migration management
- Connection pooling

### 4. Presentation Layer

**Location**: `src/presentation/`

Handles HTTP requests and responses.

#### Controllers
REST API endpoints:
- Input validation
- Request/response transformation
- Authentication/authorization
- Error handling

#### DTOs
Data Transfer Objects for API:
- Input validation with class-validator
- OpenAPI documentation with Swagger decorators
- Type safety

## Data Flow

### Example: Create Service Order

```typescript
1. Client Request (HTTP POST)
   ↓
2. Controller (ServiceOrderController)
   - Validates DTO
   - Authenticates user
   ↓
3. Use Case (CreateServiceOrderUseCase)
   - Validates customer exists
   - Validates vehicle exists
   - Validates services exist
   - Validates parts stock
   - Calculates total
   ↓
4. Domain Entity (ServiceOrder)
   - Validates business rules
   - Creates entity
   ↓
5. Repository Adapter (ServiceOrderRepository)
   - Maps entity to Prisma model
   - Persists to database
   ↓
6. Database (PostgreSQL)
   - Stores data
   ↓
7. Response flows back up
   ↓
8. Client Response (HTTP 201)
```

## Design Patterns

### 1. Dependency Injection

Used throughout the application via NestJS DI container:

```typescript
@Injectable()
export class CreateCustomerUseCase {
  constructor(
    private readonly customerRepository: CustomerRepositoryPort,
  ) {}
}
```

### 2. Repository Pattern

Abstracts data access:

```typescript
// Port (Interface)
export interface CustomerRepositoryPort {
  create(customer: Customer): Promise<Customer>;
  findById(id: string): Promise<Customer | null>;
}

// Adapter (Implementation)
@Injectable()
export class CustomerRepository implements CustomerRepositoryPort {
  constructor(private readonly prisma: PrismaService) {}
  
  async create(customer: Customer): Promise<Customer> {
    // Prisma implementation
  }
}
```

### 3. Value Object Pattern

Encapsulates validation logic:

```typescript
export class Document {
  private readonly value: string;
  
  constructor(value: string, type: DocumentType) {
    this.validate(value, type);
    this.value = value;
  }
  
  private validate(value: string, type: DocumentType): void {
    // Validation logic
  }
}
```

### 4. Use Case Pattern

Encapsulates business operations:

```typescript
@Injectable()
export class CreateCustomerUseCase {
  async execute(data: CustomerProps): Promise<Customer> {
    // Business logic
  }
}
```

## Testing Strategy

### Unit Tests

Test each layer in isolation:

```typescript
// Domain Entity Test
describe('Customer Entity', () => {
  it('should create valid customer', () => {
    const customer = new Customer(validProps);
    expect(customer.getName()).toBe('John Doe');
  });
});

// Use Case Test (with mocked repository)
describe('CreateCustomerUseCase', () => {
  it('should create customer', async () => {
    const mockRepo = {
      create: jest.fn().mockResolvedValue(customer),
      findByDocument: jest.fn().mockResolvedValue(null),
    };
    
    const useCase = new CreateCustomerUseCase(mockRepo);
    const result = await useCase.execute(data);
    
    expect(result).toBeDefined();
  });
});
```

### Integration Tests

Test adapter implementations:

```typescript
describe('CustomerRepository', () => {
  it('should save customer to database', async () => {
    const repository = new CustomerRepository(prisma);
    const customer = new Customer(validProps);
    
    const saved = await repository.create(customer);
    
    expect(saved.getId()).toBeDefined();
  });
});
```

### E2E Tests

Test complete flows:

```typescript
describe('Create Customer (e2e)', () => {
  it('POST /customers', () => {
    return request(app.getHttpServer())
      .post('/customers')
      .send(createCustomerDto)
      .expect(201);
  });
});
```

## Benefits of This Architecture

### 1. **Testability**
- Domain logic isolated from infrastructure
- Easy to mock dependencies
- Fast unit tests

### 2. **Maintainability**
- Clear separation of concerns
- Easy to locate code
- Predictable structure

### 3. **Flexibility**
- Easy to change database (swap Prisma adapter)
- Easy to change API framework (swap NestJS)
- Easy to add new features

### 4. **Business Logic Protection**
- Domain logic independent of frameworks
- Business rules centralized
- Technology changes don't affect business logic

### 5. **Team Scalability**
- Clear boundaries between layers
- Multiple developers can work in parallel
- Reduced merge conflicts

## Module Organization

Each business module follows the same structure:

```
customer.module.ts
├── Controllers (Presentation)
│   └── CustomerController
├── Use Cases (Application)
│   ├── CreateCustomerUseCase
│   ├── UpdateCustomerUseCase
│   └── ...
├── Ports (Application)
│   └── CustomerRepositoryPort
└── Adapters (Infrastructure)
    └── CustomerRepository
```

## Configuration

Modules are wired together using NestJS dependency injection:

```typescript
@Module({
  controllers: [CustomerController],
  providers: [
    {
      provide: CustomerRepositoryPort,
      useClass: CustomerRepository,
    },
    CreateCustomerUseCase,
    UpdateCustomerUseCase,
    // ...
  ],
})
export class CustomerModule {}
```

## Best Practices

1. **Dependencies point inward**: Outer layers depend on inner layers, never the reverse
2. **Pure domain**: Keep domain layer free of framework code
3. **Single responsibility**: Each class has one reason to change
4. **Interface segregation**: Small, focused interfaces
5. **Dependency inversion**: Depend on abstractions, not concretions

## Further Reading

- [Hexagonal Architecture by Alistair Cockburn](https://alistair.cockburn.us/hexagonal-architecture/)
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design by Eric Evans](https://www.domainlanguage.com/ddd/)

