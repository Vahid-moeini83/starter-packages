# Authentication & Authorization

## Authentication

### Laravel Sanctum (API Tokens)

```php
// Issue token
$token = $user->createToken('token-name')->plainTextToken;

// Protect routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});

// Revoke tokens
$user->tokens()->delete(); // All tokens
$user->currentAccessToken()->delete(); // Current token
```

### Session-Based Authentication

```php
// Login
Auth::attempt(['email' => $email, 'password' => $password]);

// Logout
Auth::logout();

// Check authentication
if (Auth::check()) {
    // User is authenticated
}

// Get authenticated user
$user = Auth::user();
```

## Authorization

### Gates

```php
// Define gate
Gate::define('update-post', function (User $user, Post $post) {
    return $user->id === $post->user_id;
});

// Check gate
if (Gate::allows('update-post', $post)) {
    // User can update post
}

// In controller
$this->authorize('update-post', $post);
```

### Policies

```php
// Generate policy
php artisan make:policy PostPolicy --model=Post

// Policy class
class PostPolicy
{
    public function update(User $user, Post $post)
    {
        return $user->id === $post->user_id;
    }

    public function delete(User $user, Post $post)
    {
        return $user->id === $post->user_id || $user->isAdmin();
    }
}

// Usage in controller
$this->authorize('update', $post);

// Usage in Blade
@can('update', $post)
    <a href="/posts/{{ $post->id }}/edit">Edit</a>
@endcan
```

## Role-Based Access Control (RBAC)

### Database Structure

```php
// users table
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('email')->unique();
    $table->string('password');
});

// roles table
Schema::create('roles', function (Blueprint $table) {
    $table->id();
    $table->string('name')->unique();
});

// permissions table
Schema::create('permissions', function (Blueprint $table) {
    $table->id();
    $table->string('name')->unique();
});

// role_user pivot
Schema::create('role_user', function (Blueprint $table) {
    $table->foreignId('user_id');
    $table->foreignId('role_id');
});

// permission_role pivot
Schema::create('permission_role', function (Blueprint $table) {
    $table->foreignId('role_id');
    $table->foreignId('permission_id');
});
```

### Model Relationships

```php
class User extends Model
{
    public function roles()
    {
        return $this->belongsToMany(Role::class);
    }

    public function hasRole($role)
    {
        return $this->roles->contains('name', $role);
    }

    public function hasPermission($permission)
    {
        return $this->roles()->whereHas('permissions', function ($q) use ($permission) {
            $q->where('name', $permission);
        })->exists();
    }
}

class Role extends Model
{
    public function permissions()
    {
        return $this->belongsToMany(Permission::class);
    }
}
```

### Middleware

```php
// Check role
Route::middleware(['role:admin'])->group(function () {
    // Admin routes
});

// Check permission
Route::middleware(['permission:edit-posts'])->group(function () {
    // Routes requiring permission
});
```

## Multi-Factor Authentication (MFA)

- Implement 2FA using TOTP (Time-based One-Time Password)
- Provide backup codes
- Allow users to enable/disable MFA
- Consider SMS or email as alternatives

## Password Management

```php
// Password reset
Password::sendResetLink(['email' => $request->email]);

// Hash passwords
$user->password = Hash::make($request->password);

// Verify password
if (Hash::check($request->password, $user->password)) {
    // Password matches
}

// Password requirements
'password' => ['required', 'confirmed', 'min:8', 'regex:/[A-Z]/', 'regex:/[0-9]/']
```

## Best Practices

- Always hash passwords (never store plain text)
- Use HTTPS in production
- Implement rate limiting on auth endpoints
- Log authentication events
- Expire old sessions
- Implement account lockout after failed attempts
- Use secure session configuration
- Rotate API tokens periodically
- Implement token refresh mechanism
- Audit authorization logic regularly

## API Authentication

```php
// Token in header
Authorization: Bearer {token}

// Rate limiting
Route::middleware('throttle:60,1')->group(function () {
    // 60 requests per minute
});
```

## Testing Authentication

```php
// Act as authenticated user
$this->actingAs($user)->get('/dashboard');

// Test authorization
$response = $this->actingAs($user)->delete("/posts/{$post->id}");
$response->assertForbidden();
```

---

_This is a starter template. Customize based on your project needs._
