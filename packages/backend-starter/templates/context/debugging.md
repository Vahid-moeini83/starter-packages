# General Debugging Best Practices & Guardrails

## 🛑 Guardrails for AI Agent

- **NO LEAKED DEBUG CODE**: DO NOT leave debugging statements (`console.log`, `print`, `pdb`, `debugger`, `dump()`) in code meant for production commits.
- **NO BLIND FIXES**: Do not make speculative code changes without analyzing the logs, error traces, or understanding the root cause.

## 📏 Standards

- **Centralized Logs**: Rely on centralized logging and Application Performance Monitoring (APM) tools (e.g., Sentry, Datadog, New Relic) to debug production environments.
- **Reproducibility**: Always attempt to reproduce the bug locally or in a staging environment before implementing a fix.

## 💡 Best Practices

- **Test-Driven Debugging**: Write a failing unit or integration test that reproduces the bug _before_ modifying the application code. Fix the code to make the test pass.
- **Scientific Method**:
  1. Gather data (logs, metrics, user reports).
  2. Formulate a hypothesis.
  3. Propose adding targeted logging if more data is needed, OR propose a fix.
  4. Test the fix.
- **Systematic Checking**: Check the entire stack systematically: network requests, load balancer rules, application logs, database query performance, and infrastructure metrics.
