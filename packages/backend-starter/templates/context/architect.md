# General Architecture Best Practices & Guardrails

## 🛑 Guardrails for AI Agent

- **NO CYCLIC DEPENDENCIES**: Prevent circular imports and cyclic dependencies between modules, packages, or services.
- **NO TIGHT COUPLING**: Do not tightly couple business logic to infrastructure (e.g., HTTP frameworks, database ORMs). Favor interfaces, ports, and adapters.

## 📏 Standards

- **Layered / Clean Architecture**: Separate application concerns into distinct layers:
  1. **Domain/Entities**: Core business rules.
  2. **Use Cases/Services**: Application-specific business rules.
  3. **Adapters/Controllers**: Gateways, HTTP controllers.
  4. **Infrastructure**: Database, external APIs, frameworks.
- **Statelessness**: Backend application instances must be stateless to enable horizontal scaling. Store session state in a database or distributed cache.

## 💡 Best Practices

- **Modularity (DDD)**: Group related code by Domain/Feature rather than strictly by technical type (e.g., favor `/users/` module over monolithic `/controllers` and `/models` folders).
- **Asynchronous Processing**: Offload heavy, non-blocking tasks (email sending, report generation, webhooks) to asynchronous background queues/workers (e.g., RabbitMQ, Celery, BullMQ).
- **Design Patterns**: Use well-known design patterns (Factory, Dependency Injection, Strategy) where appropriate to make code testable and maintainable.
