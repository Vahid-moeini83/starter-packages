# Testing Guidelines

## Testing Strategy

- Write tests for critical business logic
- Test edge cases and error conditions
- Maintain good test coverage
- Follow testing pyramid: more unit tests, fewer feature tests

## Test Types

### Unit Tests

Test individual methods and classes in isolation

```php
class OrderCalculatorTest extends TestCase
{
    public function test_calculates_total_with_tax()
    {
        $calculator = new OrderCalculator();
        $total = $calculator->calculateTotal(100, 0.1);

        $this->assertEquals(110, $total);
    }
}
```

### Feature Tests

Test complete features and user flows

```php
class OrderCreationTest extends TestCase
{
    public function test_user_can_create_order()
    {
        $user = User::factory()->create();
        $product = Product::factory()->create();

        $response = $this->actingAs($user)->post('/orders', [
            'product_id' => $product->id,
            'quantity' => 2,
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('orders', [
            'user_id' => $user->id,
            'product_id' => $product->id,
        ]);
    }
}
```

### Integration Tests

Test integration between components

```php
class PaymentIntegrationTest extends TestCase
{
    public function test_processes_payment_successfully()
    {
        $order = Order::factory()->create();

        $result = PaymentService::process($order);

        $this->assertTrue($result->isSuccessful());
        $this->assertDatabaseHas('payments', [
            'order_id' => $order->id,
            'status' => 'completed',
        ]);
    }
}
```

## Laravel Testing Features

### Database Testing

```php
use RefreshDatabase; // Reset database after each test

// Factories
User::factory()->count(3)->create();
Order::factory()->withItems()->create();

// Assertions
$this->assertDatabaseHas('users', ['email' => 'test@example.com']);
$this->assertDatabaseMissing('users', ['email' => 'deleted@example.com']);
```

### HTTP Testing

```php
$response = $this->get('/api/users');
$response->assertStatus(200);
$response->assertJson(['data' => []]);
$response->assertJsonStructure(['data', 'meta']);
$response->assertJsonFragment(['name' => 'John']);
```

### Authentication Testing

```php
$user = User::factory()->create();
$this->actingAs($user);

$response = $this->get('/dashboard');
$response->assertStatus(200);
```

## Mocking

### Mock External Services

```php
public function test_sends_notification()
{
    Mail::fake();

    $user = User::factory()->create();
    $user->notify(new WelcomeNotification());

    Mail::assertSent(WelcomeMail::class, function ($mail) use ($user) {
        return $mail->hasTo($user->email);
    });
}
```

### Mock Time

```php
public function test_subscription_expires()
{
    $this->travel(30)->days();

    // Test expiration logic
}
```

## Test Organization

```
tests/
├── Unit/
│   ├── Models/
│   ├── Services/
│   └── Helpers/
├── Feature/
│   ├── Api/
│   ├── Auth/
│   └── Admin/
└── Integration/
```

## Best Practices

### AAA Pattern

```php
public function test_example()
{
    // Arrange
    $user = User::factory()->create();

    // Act
    $result = $user->performAction();

    // Assert
    $this->assertTrue($result);
}
```

### Test Naming

```php
// Good
public function test_user_cannot_delete_others_posts()

// Bad
public function testDelete()
```

### Keep Tests Independent

```php
// Good - Each test creates its own data
public function test_feature_one()
{
    $user = User::factory()->create();
    // Test logic
}

public function test_feature_two()
{
    $user = User::factory()->create();
    // Test logic
}

// Bad - Tests depend on shared state
```

## What to Test

✅ **Do test:**

- Business logic and calculations
- API endpoints
- Validation rules
- Authorization logic
- Edge cases and error handling
- Database queries and relationships
- Critical user flows

❌ **Don't test:**

- Framework features
- Third-party library internals
- Trivial getters/setters
- Private methods (test through public interface)

## Code Coverage

```bash
# Generate coverage report
php artisan test --coverage

# Minimum coverage threshold
php artisan test --coverage --min=80
```

## Continuous Integration

```yaml
# Example GitHub Actions
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: php artisan test
```

## Testing Commands

```bash
# Run all tests
php artisan test

# Run specific test
php artisan test --filter=test_user_can_create_order

# Run test suite
php artisan test tests/Feature

# Parallel testing
php artisan test --parallel

# Generate coverage
php artisan test --coverage
```

---

_This is a starter template. Customize based on your project needs._
