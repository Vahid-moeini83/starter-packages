# Debugging Guidelines

## Laravel Debugging Tools

### Debug Mode

```env
# Enable in development only
APP_DEBUG=true
APP_ENV=local
```

### Laravel Telescope

```bash
# Install
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate

# Access at /telescope
```

### Laravel Debugbar

```bash
# Install
composer require barryvdh/laravel-debugbar --dev

# View at bottom of page in development
```

## Logging

### Log Levels

```php
Log::emergency($message);
Log::alert($message);
Log::critical($message);
Log::error($message);
Log::warning($message);
Log::notice($message);
Log::info($message);
Log::debug($message);
```

### Contextual Logging

```php
Log::info('User login', [
    'user_id' => $user->id,
    'ip' => $request->ip(),
    'timestamp' => now()
]);
```

### Custom Log Channels

```php
// config/logging.php
'channels' => [
    'custom' => [
        'driver' => 'single',
        'path' => storage_path('logs/custom.log'),
    ],
],

// Usage
Log::channel('custom')->info('Custom log message');
```

## Debugging Techniques

### Dump and Die

```php
dd($variable); // Dump and stop execution
dump($variable); // Dump and continue

// Multiple variables
dd($user, $order, $payment);
```

### Ray (Advanced Debugging)

```bash
composer require spatie/laravel-ray
```

```php
ray($user);
ray($user, $order)->green();
ray()->table($users);
ray()->showQueries();
```

### Query Debugging

```php
// Log all queries
DB::listen(function ($query) {
    Log::info($query->sql);
    Log::info($query->bindings);
    Log::info($query->time);
});

// Enable query log
DB::enableQueryLog();
// Run queries
$queries = DB::getQueryLog();
dd($queries);
```

### Tinker (REPL)

```bash
php artisan tinker

# Try code interactively
>>> $user = User::first();
>>> $user->orders;
>>> Order::where('status', 'pending')->count();
```

## Common Issues & Solutions

### N+1 Query Problem

```php
// Problem
$users = User::all();
foreach ($users as $user) {
    echo $user->posts->count(); // N+1 queries
}

// Solution
$users = User::with('posts')->get();
foreach ($users as $user) {
    echo $user->posts->count(); // 2 queries only
}
```

### Memory Issues

```php
// Problem
$users = User::all(); // Loads all into memory

// Solution
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // Process
    }
});

// Or use cursor
foreach (User::cursor() as $user) {
    // Process one at a time
}
```

### Queue Debugging

```bash
# Run queue worker in verbose mode
php artisan queue:work --tries=3 -vvv

# Retry failed jobs
php artisan queue:retry all

# Clear failed jobs
php artisan queue:flush
```

## Performance Debugging

### Laravel Telescope Queries Tab

- View slow queries
- Analyze query count per request
- Identify N+1 problems

### Clockwork

```bash
composer require itsgoingd/clockwork
```

- View in browser devtools
- Track requests, database, cache, events

### Profiling

```php
// Measure execution time
$start = microtime(true);
// Code to profile
$time = microtime(true) - $start;
Log::info("Execution time: {$time}s");
```

## API Debugging

### Request/Response Logging

```php
// Middleware
public function handle($request, Closure $next)
{
    Log::info('API Request', [
        'url' => $request->fullUrl(),
        'method' => $request->method(),
        'input' => $request->all(),
    ]);

    $response = $next($request);

    Log::info('API Response', [
        'status' => $response->status(),
        'content' => $response->getContent(),
    ]);

    return $response;
}
```

### Testing API with Tinker

```php
>>> $response = Http::post('https://api.example.com/endpoint', ['key' => 'value']);
>>> $response->status();
>>> $response->json();
```

## Error Tracking

### Sentry Integration

```bash
composer require sentry/sentry-laravel
```

```env
SENTRY_LARAVEL_DSN=your-sentry-dsn
```

### Custom Error Pages

```
resources/views/errors/
├── 404.blade.php
├── 500.blade.php
└── 503.blade.php
```

## Debugging Tools

- **Xdebug**: Step-through debugging
- **Telescope**: Request/query monitoring
- **Debugbar**: Development debugging
- **Ray**: Advanced debugging
- **Tinker**: Interactive REPL
- **Clockwork**: Browser devtools integration

## Best Practices

- Use descriptive variable and function names
- Add meaningful log messages
- Remove debug code before committing
- Use appropriate log levels
- Don't expose sensitive data in logs
- Test error scenarios
- Use try-catch blocks appropriately
- Monitor production errors

---

_This is a starter template. Customize based on your project needs._
