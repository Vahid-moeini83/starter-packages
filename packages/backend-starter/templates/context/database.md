# Database Guidelines

## Database Design

- Normalize data to reduce redundancy
- Use appropriate data types for columns
- Define clear primary and foreign keys
- Create indexes for frequently queried columns
- Use database constraints (NOT NULL, UNIQUE, CHECK)

## Migrations

- Make migrations reversible
- Test migrations on local and staging before production
- Never modify existing migrations after deployment
- Include data migrations when needed
- Document complex migrations

## Query Optimization

- Use indexes strategically
- Avoid N+1 query problems
- Use eager loading for relationships
- Limit result sets when possible
- Profile slow queries and optimize

## Laravel Eloquent Best Practices

```php
// Use eager loading to avoid N+1
$users = User::with('posts')->get();

// Use chunking for large datasets
User::chunk(200, function ($users) {
    foreach ($users as $user) {
        // Process user
    }
});

// Use database transactions
DB::transaction(function () {
    // Multiple database operations
});
```

## Security

- Always use parameterized queries (Eloquent/Query Builder does this)
- Never trust user input in raw queries
- Implement proper access controls
- Encrypt sensitive data at rest
- Use database-level constraints for data integrity

## Backup & Recovery

- Implement automated backups
- Test restore procedures regularly
- Keep backups in separate location
- Document recovery process
- Monitor backup success

## Connection Management

- Use connection pooling
- Configure appropriate timeout values
- Handle connection failures gracefully
- Monitor connection usage
- Close connections properly

---

_This is a starter template. Customize based on your project needs._
