---
name: api-saas-multitenant
description: Reviews, designs and changes APIs for business software sold to many organisations from one deployment. Covers tenant isolation, organisations and workspaces, roles and permissions, single sign-on, SCIM provisioning, per-tenant limits and noisy neighbours, audit logs, data residency, tenant export and deletion, and plan entitlements. Use when the project is a B2B or multi-tenant SaaS product, when the user mentions tenant, organisation, workspace, RBAC, SSO, SAML, SCIM, audit log or enterprise plan, or when asked to make an API safe against one customer seeing or slowing another.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Multi-tenant SaaS APIs

The one failure a business customer does not forgive is seeing another customer's data. The second is being slowed down by another customer. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. The tenant comes from the authenticated credential. A tenant named in a path, a subdomain, a header or a body is checked against the credential and never trusted alone. Do not remove such a parameter: that is a breaking change.
2. Never change tenant resolution, permission checks or data filters without the user's explicit go-ahead and a test with two tenants.
3. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance with seeded test tenants, and only after the user agrees.
4. When you find one tenant's data, keys or names in code or logs, report the file and line, never the value.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose data, leak data across tenants or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- The tenancy model: shared tables with a tenant column, a schema per tenant, a database per tenant, or cells.
- How a request finds its tenant, at the edge and in background jobs.
- The hierarchy: organisation, workspace or project, team, user, service account, API key.
- Roles, permissions and where they are checked.
- Shared things: caches, queues, search indexes, file storage, rate limiters, feature flags.
- Enterprise connections: SSO, SCIM, audit log export, customer-managed keys.
- Plans and entitlements, and where they are enforced.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can tenant A read tenant B by changing an identifier?** Read each handler. Every query must be filtered by the tenant from the credential.
2. **Do background jobs, caches and search respect the tenant?** Look for cache keys, queue messages and index queries with no tenant in them.
3. **Can one tenant exhaust shared capacity?** Look for limits and queues that are global and not per tenant.
4. **Does removing a user in the identity provider remove their access here?** Look for sessions and API keys that survive deprovisioning.
5. **Can a role be escalated through the API?** Look for endpoints where a member can set their own role or invite an owner.

## Phase 3: Report

Lead with anything that crosses a tenant boundary. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Tenant context**: resolved once, at the edge, from the credential; carried explicitly into every query, job, cache key and log line; enforced a second time by the data layer (row-level security or a mandatory scope).
- **Identifiers**: opaque and not guessable. A request for another tenant's resource answers 404, the same as a resource that does not exist.
- **Permissions**: checked on the server for every operation, against one central policy, with a test per role.
- **Limits**: per tenant and per key, with a concurrency cap, and a fair queue for background work.
- **Provisioning**: SCIM for users and groups; deprovisioning revokes sessions, tokens and keys at once.
- **Audit log**: an append-only record the customer can read and export.

## What this skill does not do

It does not give legal advice on data residency or contracts. It tells you where those reviews are needed.
