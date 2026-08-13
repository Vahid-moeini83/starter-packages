# General Testing Best Practices & Guardrails

## 🛑 Guardrails for AI Agent

- **DO NOT MOCK BUSINESS LOGIC**: Never mock the internal business logic under test. Only mock external dependencies (Databases, External APIs, 3rd party services, Message Queues).
- **TESTS MUST BE DETERMINISTIC**: Ensure tests do not rely on random data generation without seeds, specific timezones, or execution order. Tests must pass consistently.

## 📏 Standards

- **AAA Pattern**: Structure tests using Arrange, Act, Assert.
- **Coverage**: Aim for high test coverage (e.g., >80%), but prioritize critical paths over trivial getters/setters.
- **Co-location**: Keep test files close to the implementation or in a clearly mapped `tests/` directory.

## 💡 Best Practices

- **Test Pyramid**:
  - **Unit Tests**: Fast, isolated tests for individual functions/classes.
  - **Integration Tests**: Tests that interact with a real or containerized database/cache to ensure components work together.
  - **End-to-End (E2E) Tests**: Simulate real user flows through the entire system.
- **CI/CD Integration**: All tests must be runnable in a headless CI environment.
- **Test Data Builders**: Use Factories or Data Builders to generate valid test data quickly rather than hardcoding large fixture payloads.
