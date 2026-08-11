# Testing Guidelines

## Testing Strategy

- Write tests for critical business logic
- Focus on user behavior over implementation details
- Maintain good test coverage for core features
- Use the testing pyramid: more unit tests, fewer e2e tests

## Unit Testing

- Test components in isolation
- Mock external dependencies
- Test edge cases and error conditions
- Keep tests fast and focused

## Integration Testing

- Test component interactions
- Verify data flow between components
- Test with realistic data
- Mock external services

## E2E Testing

- Cover critical user journeys
- Test on multiple browsers/devices if needed
- Keep e2e tests stable and maintainable
- Run in CI/CD pipeline

## Best Practices

- Write descriptive test names
- Follow AAA pattern: Arrange, Act, Assert
- Avoid test interdependence
- Use test factories for complex data
- Clean up after tests (unmount, clear mocks)

## Accessibility Testing

- Test keyboard navigation
- Verify screen reader compatibility
- Check color contrast
- Test with accessibility tools

## What to Test

✅ **Do test:**

- User interactions and outcomes
- Business logic and calculations
- Error handling
- Edge cases
- Accessibility features

❌ **Don't test:**

- Third-party library internals
- Framework behavior
- Trivial code
- Implementation details that may change

---

_This is a starter template. Customize based on your project needs._
