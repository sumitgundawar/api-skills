# Multi-tenant SaaS API checklist

## Tenant isolation

- [ ] The tenant is derived from the credential on every request. Any tenant identifier in the path or body is checked against it and never trusted alone.
- [ ] Every data access is scoped by tenant in one place (a repository layer, a query scope or row-level security), so a new endpoint cannot forget it.
- [ ] A second layer enforces it. For example PostgreSQL row-level security with the tenant set per transaction. The application's database role is neither the table owner nor a role that bypasses row security, since both skip the policies.
- [ ] Cross-tenant access answers 404, not 403, so existence is not revealed.
- [ ] Cache keys, queue messages, search queries and file paths all include the tenant. Logs and traces carry it. Metrics carry it only where the number of tenants keeps cardinality bounded.
- [ ] Background jobs set the tenant context explicitly and fail if it is missing.
- [ ] There is an automated test, run in CI, where tenant A attempts every endpoint against tenant B's identifiers.
- [ ] Internal and support tools go through the same checks, and staff access to a tenant is time limited, reasoned and visible to the customer.

## Identity and hierarchy

- [ ] Users, service accounts and API keys are distinct principals with distinct limits.
- [ ] A user can belong to several organisations. A token is bound to one of them.
- [ ] API keys are scoped, shown once, stored hashed, carry a recognisable prefix, and can be rotated without downtime.
- [ ] Invitations expire and are bound to the invited address.

## Roles and permissions

- [ ] Permissions are checked per operation and per object (OWASP API1 and API5), not only per route.
- [ ] Callers cannot change their own role, and the last owner cannot be removed.
- [ ] Writable fields are an allowlist. A member cannot set `role`, `tenant_id` or `plan` through a general update (OWASP API3).
- [ ] Custom roles, if offered, are evaluated by the same engine as built-in ones.

## Enterprise connections

- [ ] Single sign-on supports SAML or OpenID Connect per tenant. Assertions are validated for signature, audience, recipient and time, and replays are rejected.
- [ ] A tenant can require SSO, and that rule also covers API keys and personal tokens.
- [ ] SCIM 2.0 is supported for users and groups, a repeated create answers 409 and does not duplicate, and deactivation is handled as well as deletion. SCIM endpoints keep SCIM's own error schema and index-based paging.
- [ ] Deprovisioning revokes sessions, refresh tokens and keys within minutes.
- [ ] Email domains are verified before they are used to route logins.

## Fairness and noisy neighbours

- [ ] Rate limits and concurrency caps are per tenant and per key. Limits scale with the plan.
- [ ] Background work is queued fairly, so one tenant's bulk import cannot starve the rest.
- [ ] Expensive operations (exports, reports, search) have cost-based limits and run asynchronously.
- [ ] Large tenants can be placed in their own cell or partition without an API change.
- [ ] Per-tenant usage, latency and error rates are observable.

## Audit and data

- [ ] An audit log records who did what, to what, when, from where, for every administrative and security-relevant action.
- [ ] The customer can read, filter and export it, and it cannot be edited.
- [ ] A tenant can export all of its data in a documented format.
- [ ] Tenant deletion is a pipeline with a grace period, and it reaches backups, search indexes, caches and analytics copies.
- [ ] Data residency, where promised, is enforced by where the tenant's data and its processing live, including logs and support tooling.

## Plans and entitlements

- [ ] Entitlements are checked on the server from one source of truth, not from a flag the client sends.
- [ ] Exceeding a quota returns a specific error that says which limit and how to raise it.
- [ ] A downgrade has a defined effect on data that exceeds the new plan.

## Change management

- [ ] Customers with integrations get a published version policy and notice period.
- [ ] Per-tenant feature flags do not create an unbounded number of contract variants.
- [ ] Webhooks are per tenant, signed with a per-tenant secret, and their endpoints are validated against internal addresses.

## Sources

- RFC 7643 and RFC 7644 (SCIM 2.0).
- OASIS SAML 2.0; OpenID Connect Core.
- OWASP API Security Top 10 (2023); OWASP Multi-Tenant Security Cheat Sheet.
- AWS Well-Architected, SaaS Lens.
- PostgreSQL documentation, Row Security Policies.
