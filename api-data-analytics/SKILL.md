---
name: api-data-analytics
description: Reviews, designs and changes APIs for reporting, analytics, data export, bulk import and data products. Covers long-running queries and jobs, bulk and streaming export, large result sets, ingestion at volume, freshness and consistency statements, row-level and column-level access, aggregation and re-identification risk, cost control and schema evolution. Use when the project serves reports, dashboards, exports or datasets, when the user mentions analytics, report, export, import, bulk, ETL, warehouse, query, dataset, metrics, CSV, Parquet or ingestion, or when asked to make a data API safe against runaway queries, leaked rows or silent schema changes.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Data and analytics APIs

A data API answers questions whose cost the caller chooses. One request can be a single row or a table scan, and the response can be a number or ten gigabytes. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the rules below.

## Ground rules

1. Never run queries, exports or imports against production data. Assess by reading code. Use a local or sandbox dataset that is synthetic, and only after the user agrees.
2. Never change access filters, aggregation thresholds or metric definitions without the user's explicit go-ahead and a test.
3. Never copy data out of the project. Keep rows, including sample rows, out of your own output.
4. A metric's definition is part of the contract. Changing how a number is calculated is a breaking change, even if the field name stays.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. If it reads live credentials, or points at any host that is not local or a named sandbox, do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format) keep that protocol's own errors, paging and status codes. Report a deviation from the protocol, not from this checklist.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can leak data, corrupt data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- The datasets and metrics offered, and where each definition lives.
- The ways in: single events, batches, files, streams.
- The ways out: synchronous queries, asynchronous jobs, exports, scheduled deliveries, embedded dashboards.
- The store behind each endpoint, and whether it is shared with the transactional system.
- Who may see which rows and which columns.
- Freshness: how old the data can be, and whether responses say so.
- Limits in place: time range, rows, bytes, concurrency, cost.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can one request scan everything?** Look for queries with no required time range, no row cap and no timeout.
2. **Can a caller's filter widen what they see?** Look for access filters combined with caller input in a way the caller can override, and for query text built from input.
3. **Can a small group be singled out from an aggregate?** Look for breakdowns with no minimum group size.
4. **Does an import that is retried double the data?** Look for ingestion with no batch identifier.
5. **Does a report run on the production database?** Look for analytical queries sharing the primary with user requests.

## Phase 3: Report

Lead with anything that leaks rows, lets one query starve the system or corrupts data on import. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Small queries**: synchronous, with a required time range, a row cap, a timeout and cursor pagination.
- **Large queries and exports**: a job resource with a state, progress, cancellation and an expiry; results as files behind short-lived signed links.
- **Ingestion**: batches with a client-supplied identifier, safe to repeat, validated per row with a result that lists rejects.
- **Access**: filters applied by the server from the caller's identity, in one place, and applied to exports as well as queries.
- **Freshness**: every response says the time the data is complete up to.
- **Cost**: a limit on cost per caller, and a concurrency cap on jobs.

## What this skill does not do

It does not give data protection or statistical disclosure advice. It tells you where those reviews are needed.
