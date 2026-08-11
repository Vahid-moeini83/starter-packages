# General Security Best Practices & Guardrails

## 🛑 Guardrails for AI Agent

- **NO HARDCODED SECRETS**: NEVER hardcode secrets, passwords, tokens, or API keys in the source code. Always use environment variables or a Secret Manager.
- **INJECTION PREVENTION**: Explicitly check for and prevent injection vulnerabilities (SQLi, Command Injection, XSS) when handling user input.
- **NO EVAL**: Never use `eval()` or dynamically execute arbitrary user-provided code strings.

## 📏 Standards

- **HTTPS Only**: Enforce HTTPS/TLS for all external communications.
- **Least Privilege**: Apply the Principle of Least Privilege for database roles, internal service access, and cloud IAM roles.
- **Headers**: Implement secure HTTP headers (e.g., HSTS, Content-Security-Policy, X-Frame-Options).

## 💡 Best Practices

- **Input Sanitization**: Sanitize and escape all user inputs, especially before rendering in HTML or passing to system commands.
- **Rate Limiting**: Implement rate limiting at the API gateway or application level to prevent DDoS, brute force, and credential stuffing attacks.
- **CSRF & CORS**: Configure CORS strictly (do not use `*` in production). Use CSRF tokens for session-based state-mutating requests.
- **Dependencies**: Regularly scan and update third-party dependencies for known vulnerabilities.
