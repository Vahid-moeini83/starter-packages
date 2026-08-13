# General Scaling Best Practices & Guardrails

## 🛑 Guardrails for AI Agent

- **NO SINGLE POINTS OF FAILURE**: Architect systems to avoid Single Points of Failure (SPOF). Ensure redundancy for critical components (DBs, caches, load balancers).
- **OPTIMIZE BEFORE REWRITING**: When analyzing bottlenecks, prioritize caching, database indexing, and query optimization before suggesting large-scale architecture rewrites.

## 📏 Standards

- **Horizontal over Vertical**: Design services to scale out (horizontal scaling - adding more instances) rather than scaling up (vertical scaling - adding more CPU/RAM to a single instance).
- **Statelessness**: Ensure the application tier is fully stateless. User sessions and temporary data must reside in a distributed datastore.

## 💡 Best Practices

- **Database Scaling**:
  - Use Read Replicas for read-heavy workloads.
  - Implement database partitioning or sharding for massive datasets.
- **Offload Work**:
  - Serve static assets and media via CDN.
  - Offload long-running or CPU-intensive tasks to asynchronous background workers.
- **Rate Limiting & Load Shedding**: Protect the system from traffic spikes by implementing rate limiting and, under extreme load, graceful load shedding to preserve core functionality.
- **Auto-scaling**: Configure auto-scaling groups based on appropriate metrics (CPU, Memory, Request Latency, Queue Depth).
