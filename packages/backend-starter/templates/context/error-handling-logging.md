# Error Handling & Logging

## Error Handling Strategy

- Catch exceptions at appropriate levels
- Provide meaningful error messages to users
- Log detailed error information for debugging
- Don't expose sensitive information in error responses
- Implement global exception handler

## Laravel Exception Handling

### Custom Exception Handler

```php
// app/Exceptions/Handler.php
public function register()
{
    $this->reportable(function (Throwable $e) {
        // Custom logging logic
    });

    $this->renderable(function (NotFoundHttpException $e, $request) {
        if ($request->is('api/*')) {
            return response()->json([
                'error' => 'Resource not found'
            ], 404);
        }
    });
}
```

### Custom Exceptions

```php
namespace App\Exceptions;

class InsufficientFundsException extends Exception
{
    public function render($request)
    {
        return response()->json([
            'error' => 'Insufficient funds for this transaction'
        ], 422);
    }
}
```

## Logging Levels

- **DEBUG**: Detailed information for debugging
- **INFO**: General informational messages
- **NOTICE**: Normal but significant events
- **WARNING**: Warning messages
- **ERROR**: Error conditions
- **CRITICAL**: Critical conditions
- **ALERT**: Action must be taken immediately
- **EMERGENCY**: System is unusable

## Logging Best Practices

```php
// Include context
Log::info('User logged in', ['user_id' => $user->id]);

// Log exceptions with context
Log::error('Payment failed', [
    'user_id' => $user->id,
    'amount' => $amount,
    'exception' => $e->getMessage()
]);

// Use appropriate log levels
Log::debug('Query executed', ['query' => $query]);
Log::warning('Deprecated method called', ['method' => $method]);
Log::critical('Database connection lost');
```

## Structured Logging

```php
// Good: Structured logging
Log::info('Order created', [
    'order_id' => $order->id,
    'user_id' => $user->id,
    'total' => $order->total,
    'items_count' => $order->items->count()
]);

// Bad: Unstructured logging
Log::info("Order {$order->id} created for user {$user->id}");
```

## What to Log

✅ **Do log:**

- User authentication events
- Authorization failures
- Payment transactions
- API requests (with sanitized data)
- System errors and exceptions
- Performance metrics
- Database query errors
- External API calls

❌ **Don't log:**

- Passwords or secrets
- Credit card numbers
- Personal identification numbers
- Session tokens
- API keys
- Excessive debug information in production

## Log Channels

```php
// config/logging.php
'channels' => [
    'stack' => [
        'driver' => 'stack',
        'channels' => ['single', 'slack'],
    ],
    'payments' => [
        'driver' => 'daily',
        'path' => storage_path('logs/payments.log'),
        'level' => 'info',
    ],
];

// Usage
Log::channel('payments')->info('Payment processed', $data);
```

## Error Monitoring

- Integrate error tracking service (Sentry, Bugsnag, etc.)
- Set up alerts for critical errors
- Monitor error rates and patterns
- Review logs regularly
- Set up log rotation

## User-Friendly Error Messages

```php
// Development
'debug' => env('APP_DEBUG', false),

// Production - Generic messages
try {
    // Operation
} catch (Exception $e) {
    Log::error('Operation failed', ['exception' => $e]);

    return response()->json([
        'error' => 'An error occurred. Please try again later.'
    ], 500);
}
```

## Testing Error Handling

- Test error scenarios
- Verify error responses
- Check logging behavior
- Test exception handlers
- Validate error messages

---

_This is a starter template. Customize based on your project needs._
