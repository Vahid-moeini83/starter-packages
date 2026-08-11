# Security Guidelines

## Authentication & Authorization

- Use Laravel Sanctum or Passport for API authentication
- Implement proper password hashing (bcrypt/argon2)
- Use middleware for route protection
- Implement role-based access control (RBAC)
- Use policy classes for authorization logic

## Input Validation & Sanitization

- Validate all user input
- Use Form Requests for validation logic
- Sanitize data before storage
- Never trust client data
- Implement CSRF protection for web routes

## SQL Injection Prevention

- Always use Eloquent or Query Builder
- Never concatenate user input in raw queries
- Use parameter binding for raw queries
- Validate and sanitize database inputs

## XSS Prevention

- Use Blade's `{{ }}` for automatic escaping
- Be cautious with `{!! !!}` unescaped output
- Sanitize user-generated HTML content
- Implement Content Security Policy (CSP)

## CSRF Protection

- Enabled by default in Laravel
- Include `@csrf` directive in forms
- Verify CSRF token on state-changing operations
- Exclude API routes from CSRF middleware

## API Security

- Rate limit API endpoints
- Implement proper CORS configuration
- Use API tokens securely
- Validate API requests
- Log suspicious activities

## File Upload Security

- Validate file types and sizes
- Store files outside public directory
- Use random filenames
- Scan for malware if possible
- Set proper file permissions

## Encryption & Hashing

- Use Laravel's encryption for sensitive data
- Hash passwords with bcrypt/argon2
- Encrypt data at rest when necessary
- Use HTTPS in production
- Rotate encryption keys regularly

## Error Handling

- Don't expose stack traces in production
- Log errors securely
- Return generic error messages to users
- Monitor error patterns
- Implement proper exception handling

## Dependencies

- Keep Laravel and packages updated
- Run security audits (`composer audit`)
- Review dependencies before adding
- Remove unused packages
- Pin versions in production

## Environment Configuration

- Never commit `.env` file
- Use strong `APP_KEY`
- Disable debug mode in production
- Secure session configuration
- Use secure cookie settings

## Headers & Security

```php
// Configure in middleware
'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
'X-Content-Type-Options' => 'nosniff',
'X-Frame-Options' => 'SAMEORIGIN',
'X-XSS-Protection' => '1; mode=block',
'Referrer-Policy' => 'strict-origin-when-cross-origin',
```

## Laravel Security Features

- Use `Gate` and `Policy` for authorization
- Implement `throttle` middleware for rate limiting
- Use `signed` routes for temporary URLs
- Encrypt sensitive model attributes
- Use database query logging in development only

---

_This is a starter template. Customize based on your project needs._
