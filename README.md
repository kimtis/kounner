# kounner

`kounner` is a Kubernetes multi-cluster resource aggregation service.

## Purpose
This project synchronizes resources (Pod, Deployment, Event, CustomCRD, etc.) from multiple Kubernetes clusters into a central storage, providing a Materialized View to downstream systems (deployment systems, LLM/MCP servers) with high throughput and isolation.

## Documentation
For development guidelines, coding standards, and architectural principles, refer to [AGENTS.md](./AGENTS.md).
