---
name: api-graphql
description: Reviews, designs and changes GraphQL APIs. Covers schema design, nullability, pagination, mutations and idempotency, field-level authorisation, query cost and depth limits, persisted queries, batching and the N+1 problem, errors, deprecation and schema evolution, federation and subscriptions. Use when the project exposes or consumes GraphQL, when the user mentions schema, resolver, query, mutation, subscription, dataloader, federation, Apollo, Relay, persisted query or introspection, or when asked to make a GraphQL API safe against expensive queries, data leaks through nested fields or breaking schema changes.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.1"
---

# GraphQL APIs

GraphQL hands the caller a query language. Every question about cost, access and change that a REST API answers per endpoint, a GraphQL API has to answer per field. Use Inventory → Assess → Report for a review. For a direct design, change or explanation, use only the relevant phases; the request already authorises its scoped work. If the `api-platform-core` skill is installed, use its workflow and general decisions, then this skill for what GraphQL changes.

## Ground rules

1. A removed or renamed field, a changed type, and a field that goes from non-null to nullable are breaking changes. So, on the input side, are a new required argument or input field, an argument that goes from nullable to non-null, and a removed enum value. Never make one without the user's explicit go-ahead and usage data for that field.
2. Authorisation is checked where the data is loaded, not only at the top of the query.
3. Never send requests to production or to any shared environment, and do not run introspection or probing queries against one. Assess by reading the schema and the resolvers.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can leak data, lose data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- The schema: where it is defined, whether it is one graph or federated, and who owns each type.
- The clients: your own apps, partners, the public, and whether they send arbitrary or registered queries.
- Resolvers and what each one calls.
- How authentication reaches resolvers, and where authorisation is decided.
- Limits in place: depth, cost, rate, timeouts, body size.
- The tooling: schema registry, schema checks in CI, field usage metrics.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can a caller reach data through a nested field that the top-level check did not cover?** Trace every path to each sensitive type.
2. **Can one query do unbounded work?** Look for lists without a required limit, nested lists, and no cost analysis.
3. **Does each list of N items trigger N more calls?** Look for resolvers that fetch one by one with no batching.
4. **Can aliases or batching get round the rate limit?** Look for limits that count HTTP requests, not operations or cost.
5. **Does anyone know which fields are used?** Without field usage data, nothing can ever be removed safely.

## Phase 3: Report

Lead with anything that leaks data through the graph or lets one query take the service down. Give the evidence, an example query described in words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start when the user asks for a change, or after they choose a finding. An additive schema change is only a compatibility candidate: check strict clients, nullability, resolver cost, defaults and representative operations. Removals or behavioural changes need usage data, a migration plan and the user's agreement.

- **Lists**: connection-style pagination with a required, capped page size.
- **Cost**: a calculated cost per query, a limit per caller, and the cost returned in the response.
- **Persisted queries**: for your own clients, accept only registered operations.
- **Mutations**: one input object, a payload type that can carry domain errors, and a client-supplied idempotency key for anything that must not repeat.
- **Authorisation**: enforced in the data layer that every resolver goes through.
- **Evolution**: add, mark old fields `@deprecated` with a reason and a date, watch usage fall, then remove.

## What this skill does not do

It does not choose between GraphQL and REST for you. It makes the GraphQL you have safe to run and to change.
