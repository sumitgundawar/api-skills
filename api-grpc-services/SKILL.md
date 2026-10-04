---
name: api-grpc-services
description: Reviews, designs and changes gRPC and Protocol Buffers APIs, and service-to-service APIs inside a microservice system. Covers proto design and compatibility, field numbers, deadlines and cancellation, retries and hedging, status codes, streaming and flow control, load balancing, health checks, service identity with mutual TLS, and exposing gRPC to browsers or as REST. Use when the project has .proto files or internal service calls, when the user mentions gRPC, protobuf, proto, buf, service mesh, Envoy, deadline, unary, streaming or mTLS, or when asked to make internal APIs safe against cascading failures or breaking message changes.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# gRPC and internal service APIs

Internal APIs fail differently from public ones. The callers are few and known, but they are chained, and a slow service at the bottom takes down everything above it. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for the general decisions and use this skill for what gRPC and service chains change.

## Ground rules

1. Never reuse or renumber a field, change a field's type, or rename a package, service or method without the user's explicit go-ahead. These break callers that are already deployed, and some of them corrupt data silently.
2. Never change retry, timeout or deadline settings without stating the effect on load. A retry setting is a load multiplier.
3. Never send requests to a deployed environment. Assess by reading the proto files, the configuration and the code.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. If it reads live credentials, or points at any host that is not local or a named sandbox, do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format) keep that protocol's own errors, paging and status codes. Report a deviation from the protocol, not from this checklist.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can corrupt data, cascade a failure or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- The proto files: where they live, how they are published, who owns each package.
- The call graph: which service calls which, and how deep the chains go.
- For each call: its deadline, its retry settings, and whether it is safe to repeat.
- Streaming methods and what flows through them.
- How services find each other and how load is spread.
- How a service proves its identity to another, and what each is allowed to call.
- Checks in CI: lint, breaking-change detection.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Does every call have a deadline, and is it passed down?** A call with no deadline holds resources for ever.
2. **How many attempts reach the bottom for one request at the top?** Multiply the retries at each layer.
3. **Has a field number ever been reused or a type changed?** Look at the history of the proto files.
4. **Can any service call any method?** Look for authentication without per-method authorisation.
5. **Are long-lived connections balanced?** Look for a connection-level balancer in front of HTTP/2, which pins all calls to one backend.

## Phase 3: Report

Lead with anything that can corrupt data on the wire or turn one slow service into an outage. Give the evidence, the arithmetic where retries are involved, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. Additive proto changes are safe. Everything else needs the user's agreement and a rollout order.

- **Proto changes**: add fields with new numbers; reserve the numbers and names of anything removed; run a breaking-change check in CI.
- **Deadlines**: set at the edge, propagated on every call, and checked before starting expensive work.
- **Retries**: at one layer, with a budget, only for methods marked safe to repeat or carrying a request identifier.
- **Errors**: the standard status codes used as defined, with structured details.
- **Mutating methods**: a request identifier field so a repeat is recognised.
- **Rollout**: servers that accept the new form first, then clients that send it.

## What this skill does not do

It does not design your service boundaries. It makes the calls between the services you have safe to run and to change.
