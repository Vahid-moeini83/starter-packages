# General Authentication & Authorization (AuthN & AuthZ)

## 🛑 Guardrails for AI Agent

- **NO CUSTOM CRYPTO**: NEVER implement custom cryptography for password hashing; use industry standards (e.g., Argon2, bcrypt).
- **AUTHORIZE AT THE RESOURCE**: Always validate authorization at the backend resource/data level, not just at the UI or API Gateway level.
- **REQUIRE AUTH MIDDLEWARE**: Ensure endpoints require authentication middleware unless explicitly designed to be public.

## 📏 Standards

- **Session Management**:
  - For APIs serving SPAs/mobile apps, use JWT (JSON Web Tokens) with short expiration times and refresh tokens.
  - For traditional web apps, use secure, `HttpOnly`, `SameSite=Strict` cookies to prevent XSS and CSRF.
- **OAuth2 / OIDC**: Use standard protocols for SSO and third-party integrations rather than rolling custom identity solutions.

## 💡 Best Practices

- **Access Control Models**: Implement robust Role-Based Access Control (RBAC) or Attribute-Based Access Control (ABAC) depending on domain complexity.
- **Token Storage**: Never store JWT access tokens in `localStorage` in browser environments; prefer `HttpOnly` cookies or memory.
- **Audit Trails**: Log critical AuthN/AuthZ events (e.g., failed logins, role changes, password resets) to maintain a secure audit trail.
