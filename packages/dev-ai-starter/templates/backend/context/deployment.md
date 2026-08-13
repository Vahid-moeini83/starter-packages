# General Deployment Best Practices & Guardrails

## 🛑 Guardrails for AI Agent

- **NO UNVERIFIED DEPLOYMENTS**: NEVER deploy code that has failed CI/CD pipeline checks (linting, tests, security scans).
- **PIPELINE INTEGRITY**: Ensure pipeline steps are strictly sequential; a failure in an early stage (like testing) MUST halt the deployment process.

## 📏 Standards

- **Infrastructure as Code (IaC)**: Provision all infrastructure using code (Terraform, CloudFormation, Pulumi, Ansible). Avoid manual cloud console configurations.
- **Containerization**: Use Docker to containerize applications, ensuring the same artifact runs locally, in staging, and in production.
- **Environment Parity**: Keep development, staging, and production environments as identical as possible to avoid "works on my machine" bugs.

## 💡 Best Practices

- **Deployment Strategies**: Implement Zero-Downtime deployments using Blue-Green, Canary, or Rolling updates.
- **Automated Rollbacks**: Ensure pipelines have automated rollback mechanisms triggered by failed health checks or elevated error rates post-deployment.
- **Health Checks**: Implement robust readiness and liveness probes (`/health`, `/ready`) to allow orchestration tools (Kubernetes, ECS) to manage traffic and container lifecycles effectively.
- **Configuration Management**: Externalize configurations using Environment Variables or centralized config stores.
