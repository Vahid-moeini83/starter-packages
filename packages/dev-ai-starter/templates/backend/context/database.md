# General Database Best Practices & Guardrails

## 🛑 Guardrails for AI Agent

- **NO DESTRUCTIVE OPERATIONS**: NEVER perform destructive operations (`DROP`, `DELETE` without `WHERE`, `TRUNCATE`) unless explicitly commanded and double-verified.
- **PREVENT SQL INJECTION**: ALWAYS use parameterized queries or an ORM. Never concatenate raw strings for SQL queries.
- **NO MIGRATION TAMPERING**: Do not modify existing, applied database migrations. Always create a new migration for schema changes.

## 📏 Standards

- **Naming Conventions**:
  - Tables: `snake_case`, plural (e.g., `users`, `order_items`).
  - Columns: `snake_case` (e.g., `first_name`, `created_at`).
- **Timestamps**: All tables must include `created_at` and `updated_at` timestamps. Soft deletes should use a `deleted_at` column.
- **Primary Keys**: Use UUIDs or auto-incrementing integers for primary keys.

## 💡 Best Practices

- **Connection Pooling**: Always configure and use database connection pooling to handle concurrent requests efficiently.
- **Indexing**: Add indexes for frequently queried columns, foreign keys, and columns used in `WHERE`, `JOIN`, or `ORDER BY` clauses.
- **N+1 Problem**: Avoid the N+1 query problem by using JOINs, eager loading, or dataloaders.
- **Transactions**: Wrap multiple related write operations within a database transaction to ensure ACID compliance.
