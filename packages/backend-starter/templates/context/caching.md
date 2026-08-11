# Caching Guidelines

## Caching Strategy

- Cache expensive operations
- Cache frequently accessed data
- Set appropriate TTL (Time To Live)
- Implement cache invalidation strategy
- Use cache tags for organized invalidation

## Laravel Caching

### Cache Drivers

- **File**: Simple, file-based cache (development)
- **Database**: Store cache in database
- **Redis**: Fast, in-memory cache (recommended for production)
- **Memcached**: Distributed memory caching

### Basic Usage

```php
// Store cache
Cache::put('key', 'value', $seconds);
Cache::put('key', 'value', now()->addMinutes(10));

// Retrieve cache
$value = Cache::get('key');
$value = Cache::get('key', 'default');

// Remember (get or store)
$users = Cache::remember('users', 3600, function () {
    return User::all();
});

// Forever cache
Cache::forever('key', 'value');

// Check existence
if (Cache::has('key')) {
    //
}

// Delete cache
Cache::forget('key');
Cache::flush(); // Clear all cache
```

## Cache Tags

```php
// Store with tags
Cache::tags(['users', 'admin'])->put('john', $user, 3600);

// Retrieve with tags
$user = Cache::tags(['users', 'admin'])->get('john');

// Flush tagged cache
Cache::tags(['users'])->flush();
Cache::tags(['users', 'admin'])->flush();
```

## Caching Patterns

### Model Caching

```php
class User extends Model
{
    public static function cached($id)
    {
        return Cache::remember("user.{$id}", 3600, function () use ($id) {
            return static::find($id);
        });
    }

    protected static function boot()
    {
        parent::boot();

        static::updated(function ($user) {
            Cache::forget("user.{$user->id}");
        });
    }
}
```

### Query Result Caching

```php
$products = Cache::remember('products.featured', 3600, function () {
    return Product::where('featured', true)
        ->with('category')
        ->get();
});
```

### View Fragment Caching

```blade
@cache('sidebar', now()->addHour())
    <div class="sidebar">
        {{-- Expensive sidebar content --}}
    </div>
@endcache
```

## Cache Invalidation

```php
// Clear specific cache
Cache::forget('key');

// Clear by pattern (if using Redis)
Cache::flush();

// Clear tagged cache
Cache::tags(['products'])->flush();

// Conditional cache clearing
if ($product->wasChanged('price')) {
    Cache::forget("product.{$product->id}");
    Cache::tags(['products', 'featured'])->flush();
}
```

## What to Cache

✅ **Good candidates:**

- Database query results
- API responses from external services
- Expensive calculations
- Rendered views or fragments
- Session data
- Configuration data
- Frequently accessed models

❌ **Bad candidates:**

- User-specific real-time data
- Frequently changing data
- Large objects (> 1MB)
- Sensitive information without encryption

## Cache Best Practices

- Use descriptive cache keys
- Set appropriate expiration times
- Implement cache warming for critical data
- Monitor cache hit/miss rates
- Use cache tags for organized invalidation
- Implement fallback for cache failures
- Document caching strategy
- Test cache behavior

## Redis Configuration

```php
// config/database.php
'redis' => [
    'client' => 'phpredis',
    'default' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', 6379),
        'database' => 0,
    ],
    'cache' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', 6379),
        'database' => 1,
    ],
],
```

## Monitoring

- Track cache hit/miss ratios
- Monitor cache memory usage
- Set up alerts for cache failures
- Log cache invalidation events
- Profile cache performance

---

_This is a starter template. Customize based on your project needs._
