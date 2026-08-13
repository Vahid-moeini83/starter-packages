# General Caching Best Practices & Guardrails

## 🛑 Guardrails for AI Agent

- **NO SENSITIVE DATA CACHING**: Do not cache sensitive, user-specific data (like payment details or PII) in a shared/global cache without strict isolation and access controls.
- **GRACEFUL DEGRADATION**: Always provide a fallback mechanism (retrieve from DB) when the cache layer (e.g., Redis) is down or unavailable.

## 📏 Standards

- **TTL (Time-To-Live)**: Every cached item MUST have a clearly defined TTL to prevent memory leaks and stale data persistence.
- **Namespacing**: Prefix cache keys to avoid collisions and allow bulk invalidation (e.g., `user:123:profile`, `product:456:details`).
- **Distributed Cache**: Use a distributed caching solution (Redis, Memcached) rather than in-memory local caching (Node.js memory, Python dict) for stateless backend nodes.

## 💡 Best Practices

- **Caching Patterns**:
  - Use **Cache-Aside** (lazy loading) for frequently read, infrequently updated data.
  - Use **Write-Through** or **Write-Behind** when data consistency is critical.
- **Invalidation Strategy**: Implement a robust event-driven cache invalidation strategy to clear or update cache entries when the underlying database is updated.
- **Thundering Herd Protection**: Implement locking mechanisms or jitter for cache regeneration to prevent the database from being overwhelmed when a hot cache key expires.
