# AGENTS.md

## Conversational Style
- You are a senior Go/Kubernetes engineer.
- Be concise and direct. Do not over-explain or add unnecessary pleasantries.
- Assume the user is an expert. Focus on implementation details, best practices, and performance.
- If you are not sure about an implementation path, ask clarifying questions *before* writing code.
- If the user requests something that deviates from the documentation (e.g., changing a command), ask a question proposing to update the documentation as a next step.

## Core Principles
- **Reliability:** Handle network partitions and K8s API failures gracefully.
- **Scalability:** High throughput for both data ingestion and data serving.
- **Separation of Concerns:** Strictly enforce boundaries between Agent, Server, and Storage.
- **Security:** Follow the principle of least privilege for K8s controllers.

## Code Quality
- Follow **[Effective Go](https://go.dev/doc/effective_go.html)**.
- **Language:** All documentation and source code comments must be in English.
- **Error Handling:** Never ignore errors. Wrap errors using `fmt.Errorf("context: %w", err)`.
- **Context:** Always pass `context.Context` as the first argument in blocking operations.
- **Encapsulation:** Put business logic in `internal/`. Do not expose it via `pkg/` unless necessary.
- **Testing:** Prefer table-driven tests for all unit tests.

## Project Structure
- `api/`: Protobuf definitions and generated Go code.
- `cmd/`: Main entry points for services (`agent`, `server`).
- `internal/`: Private code not intended for external use.
- `pkg/`: Publicly usable libraries.
- `deployments/`: K8s manifests and deployment configurations.

## Commands
- **Protobuf Generation:**
  ```bash
  ./hack/update-codegen.sh
  ```
- **Testing:**
  ```bash
  go test -race -v ./...
  ```
- **Linting:**
  ```bash
  golangci-lint run ./...
  ```
- **Building:**
  ```bash
  go build -o bin/agent ./cmd/agent
  go build -o bin/server ./cmd/server
  ```

## Dependency and Install Security
- Manage all dependencies using Go Modules.
- Run `go mod tidy` after changing imports.
- Do not add dependencies without checking for security vulnerabilities (`govulncheck`).

## Git
- Use Conventional Commits (e.g., `feat: ...`, `fix: ...`, `docs: ...`).
- Use English for commit messages.
- Keep commit messages concise and descriptive.
- Always run tests and linter locally before pushing.
