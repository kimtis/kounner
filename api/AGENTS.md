# AGENTS.md

## Schema Design Principles
- **Design Philosophy:** Protobuf schemas are the source of truth for all cross-service communication in kounner. Keep messages clean, well-commented, and strictly backward-compatible.
- **Naming Conventions:** Use `snake_case` for field names. Message names must follow `PascalCase`.
- **Versioning:** Always use `syntax = "proto3"`. Avoid breaking changes. If a breaking change is mandatory, introduce a new versioned package (e.g., `api/v2/`).
- **Identification:** Every resource-related message must include the `ResourceID` message for a unified composite key: `{cluster_id, group_version, kind, namespace, name}`.
- **Payload Handling:** Use `bytes` for raw data. Always specify the data format (JSON) clearly in the field comments to ensure consistency across services.
- **Consistency:** Ensure all service communications adhere to the `ResourceEvent` envelope pattern to keep the state definition pure.
- **Generation:** Always regenerate Go code after modifying `.proto` files using the standard command. Never commit generated code that diverges from the schema.

## Service & Communication Design
- **Separation of Concerns:** Separate core data/domain schemas (`type.proto`) from RPC service interface definitions (`service.proto`).
- **Unary RPC over Streaming:** Use gRPC Unary RPC (with HTTP/2 multiplexing) instead of bidirectional streaming. This efficiently handles ~200 agents with highly skewed traffic (avoiding idle connection/timeout issues and simplifying load balancing).
- **Batching & Idempotency:** Agent-to-server event ingestion must use batch operations (e.g., `BatchUpsertResourceEvents`) with `UPSERT` semantics. Due to idempotency, full-batch retries are safe and preferred upon failure.
