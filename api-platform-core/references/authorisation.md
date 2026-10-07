# 4. Authorisation

Authorisation answers "may this caller do this, to this object". It is where most serious API vulnerabilities live. Three of the OWASP API Security Top 10 (2023) entries are authorisation failures: object level (API1), object property level (API3) and function level (API5).

Keep four questions separate. Authentication establishes the principal. A role, scope or policy may permit an action. Tenant membership limits the data boundary. Ownership or another relationship decides whether this principal may act on this exact object. A route-level role check never replaces the tenant and object checks; all applicable checks must pass.

## Checklist

- [ ] Every handler that takes an object identifier checks that the caller may access that specific object. Not just that the caller is logged in.
- [ ] The check happens on the server, on every request, close to the data access. Never rely on the client hiding a button.
- [ ] Responses are filtered per field. A caller who may read an order may not necessarily read its internal notes or cost price.
- [ ] Writes are filtered per field. A client cannot set `role`, `owner_id`, `price` or `status` just because the field exists on the model. Use an explicit allow list of writable fields.
- [ ] Administrative and internal operations live on separate routes with separate checks.
- [ ] Denied access to an object the caller should not know about returns 404, not 403, to avoid confirming that it exists. Be consistent.
- [ ] List endpoints are scoped by the caller's permissions in the query, not filtered afterwards in memory.
- [ ] Authorisation decisions are logged with the caller, the object, the action and the result.
- [ ] Tests distinguish a missing role or scope from cross-tenant access and wrong-object access. Each path is denied independently.

## Models

- Role-based checks are fine for a small, fixed set of roles.
- When access depends on relationships (owner, member of a team that owns a folder), use a relationship-based model. Google's Zanzibar is the reference design. The paper reports more than 10 million client queries a second, with 95th percentile latency under 10 milliseconds, and it returns a consistency token so that a permission check is never staler than the content change that preceded it.
- Keep the decision separate from the enforcement. The OpenID AuthZEN Authorization API 1.0 (final, January 2026) standardises the call between the two.

## Multi-tenancy

- The tenant identifier comes from the credential, never from the request body or path alone.
- Every query includes the tenant. Enforce this in one place, such as a repository layer or row-level security, so that a new endpoint cannot forget it.

## Sources

- OWASP API Security Top 10, 2023 edition: https://owasp.org/API-Security/
- Pang et al. Zanzibar: Google's Consistent, Global Authorization System. USENIX ATC 2019.
- OpenID Foundation, Authorization API 1.0 (AuthZEN), final specification, January 2026.
