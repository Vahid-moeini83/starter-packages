# General Error Handling & Logging Best Practices

## 🛑 Guardrails for AI Agent

- **NO PII IN LOGS**: NEVER log sensitive information (PII, passwords, auth tokens, full credit card numbers, health data).
- **CATCH UNHANDLED**: Never let unhandled exceptions crash the main application process unexpectedly. Wrap risky operations in try-catch/except blocks.

## 📏 Standards

- **Structured Logging**: Use structured JSON logging to facilitate log aggregation and searching (e.g., Datadog, ELK).
- **Log Levels**:
  - `DEBUG`: Detailed information for debugging.
  - `INFO`: Normal application state changes (e.g., service started, user logged in).
  - `WARN`: Unexpected situations that don't immediately halt the system.
  - `ERROR`: System errors or exceptions that need attention.
  - `FATAL`: Critical system failure.
- **Correlation IDs**: Pass a Correlation ID (Request ID) through all layers and microservices to trace requests end-to-end.

## 💡 Best Practices

- **Fail Fast & Gracefully**: Handle known errors explicitly and return meaningful status codes to the client, while logging the stack trace internally.
- **Contextual Logs**: Include relevant context in logs (e.g., `userId`, `resourceId`, `action`) rather than just string messages.
- **Alerting**: Design logs so they can be easily converted into metrics and actionable alerts. Avoid logging at the `ERROR` level for user mistakes (like 400 Bad Request), reserve `ERROR` for system faults (500).
