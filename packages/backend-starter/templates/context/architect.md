# Architecture Guidelines

## Laravel Application Structure

- Follow Laravel conventions and best practices
- Organize code by feature when possible
- Separate concerns: Models, Controllers, Services, Repositories
- Use Service Providers for bootstrapping

## Design Patterns

### Repository Pattern

```php
interface UserRepositoryInterface
{
    public function find($id);
    public function create(array $data);
}

class UserRepository implements UserRepositoryInterface
{
    public function find($id)
    {
        return User::findOrFail($id);
    }

    public function create(array $data)
    {
        return User::create($data);
    }
}
```

### Service Layer

```php
class OrderService
{
    public function __construct(
        private OrderRepository $orderRepository,
        private PaymentService $paymentService
    ) {}

    public function createOrder(array $data): Order
    {
        $order = $this->orderRepository->create($data);
        $this->paymentService->process($order);
        return $order;
    }
}
```

### Factory Pattern

```php
class PaymentGatewayFactory
{
    public static function make(string $gateway): PaymentGatewayInterface
    {
        return match($gateway) {
            'stripe' => new StripeGateway(),
            'paypal' => new PayPalGateway(),
            default => throw new InvalidArgumentException()
        };
    }
}
```

## Project Organization

### By Feature (Domain-Driven)

```
app/
├── Domain/
│   ├── User/
│   │   ├── Models/
│   │   ├── Controllers/
│   │   ├── Services/
│   │   └── Repositories/
│   └── Order/
│       ├── Models/
│       ├── Controllers/
│       └── Services/
```

### Traditional Laravel

```
app/
├── Http/
│   ├── Controllers/
│   ├── Middleware/
│   └── Requests/
├── Models/
├── Services/
├── Repositories/
└── Providers/
```

## SOLID Principles

### Single Responsibility

- Each class should have one reason to change
- Separate business logic from infrastructure

### Open/Closed

- Open for extension, closed for modification
- Use interfaces and abstract classes

### Liskov Substitution

- Derived classes must be substitutable for base classes
- Follow interface contracts

### Interface Segregation

- Many specific interfaces better than one general
- Don't force classes to implement unused methods

### Dependency Inversion

- Depend on abstractions, not concretions
- Use dependency injection

## Dependency Injection

```php
class OrderController extends Controller
{
    public function __construct(
        private OrderService $orderService,
        private PaymentService $paymentService
    ) {}

    public function store(OrderRequest $request)
    {
        $order = $this->orderService->create($request->validated());
        return response()->json($order, 201);
    }
}
```

## API Design

- Use Laravel API Resources for responses
- Implement versioning strategy
- Follow RESTful conventions
- Use Form Requests for validation
- Implement proper error handling

## Database Design

- Normalize data appropriately
- Use migrations for all schema changes
- Implement proper indexes
- Use foreign key constraints
- Consider soft deletes for important data

## Code Organization Best Practices

- Keep controllers thin (delegate to services)
- Extract complex queries to repositories
- Use Events and Listeners for side effects
- Implement Policies for authorization
- Use Jobs for async operations
- Cache expensive operations

## Testing Architecture

- Write tests for business logic
- Test API endpoints
- Mock external dependencies
- Use factories for test data
- Keep tests independent

---

_This is a starter template. Customize based on your project needs._
