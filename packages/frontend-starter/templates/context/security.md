# Security Guidelines

## Input Validation

- Always validate and sanitize user input
- Use proper encoding for different contexts (HTML, URL, JavaScript)
- Implement client-side validation as UX enhancement, not security
- Never trust client-side data on the server

## Authentication & Authorization

- Store tokens securely (httpOnly cookies or secure storage)
- Implement proper session management
- Use refresh tokens for long-lived sessions
- Never store sensitive data in localStorage

## XSS Prevention

- Use framework built-in escaping (React's JSX, Vue templates)
- Be cautious with dangerouslySetInnerHTML or v-html
- Implement Content Security Policy (CSP)
- Sanitize user-generated content before rendering

## CSRF Protection

- Use CSRF tokens for state-changing operations
- Implement SameSite cookie attributes
- Validate origin and referer headers

## Data Protection

- Never log sensitive information
- Implement proper error handling that doesn't leak system details
- Use HTTPS everywhere
- Encrypt sensitive data at rest and in transit

## Dependencies

- Regularly update dependencies for security patches
- Use npm audit or yarn audit
- Review dependencies before adding them
- Pin versions in production

## API Security

- Use proper CORS configuration
- Implement rate limiting
- Validate API responses
- Handle errors gracefully without exposing internals

---

_This is a starter template. Customize based on your project needs._
