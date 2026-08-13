# General API Standards & Guardrails

## 🛑 Guardrails for AI Agent

- **NO BREAKING CHANGES**: Do not introduce breaking changes to existing endpoints. If a breaking change is required, suggest versioning the API (e.g., `/v1/` to `/v2/`).
- **VALIDATE EVERYTHING**: Always add validation for request payloads (body, query params, headers) before processing.
- **DO NOT LEAK INTERNALS**: Never expose internal database IDs, stack traces, or internal server logic in API responses.

## 📏 Standards

- **RESTful Conventions**:
  - Use nouns, not verbs in URLs (e.g., `/users`, not `/getUsers`).
  - Use proper HTTP Methods: `GET` (Read), `POST` (Create), `PUT` (Replace), `PATCH` (Update), `DELETE` (Remove).
- **HTTP Status Codes**:
  - `200 OK`, `201 Created`, `204 No Content`
  - `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `422 Unprocessable Entity`
  - `500 Internal Server Error`
- **Payload Format**: Use `camelCase` for JSON request and response payloads. Return data wrapped in a consistent structure.

## 💡 Best Practices

- **Pagination & Filtering**: Implement pagination (cursor-based or offset-based), filtering, and sorting for all endpoints that return lists.
- **Documentation**: Document all endpoints using OpenAPI/Swagger. Keep the documentation in sync with the code.
- **Idempotency**: Ensure `PUT`, `PATCH`, and `DELETE` requests are idempotent.
