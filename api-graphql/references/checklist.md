# GraphQL API checklist

## Schema design

- [ ] Types model the domain, not the database tables or one screen.
- [ ] Nullability is chosen on purpose. A non-null field that fails takes its whole parent with it, so fields backed by another service are usually nullable.
- [ ] Identifiers are opaque `ID` values, globally unique where clients cache by them.
- [ ] Enums are used knowing that a new value can break a client with no default case. Clients are told to handle unknown values.
- [ ] Custom scalars (dates, money, URLs) have a written format. Money is not a float.
- [ ] Every field and argument has a description. The schema is the documentation.

## Pagination and lists

- [ ] Every list field that can grow takes a page size argument with a server-enforced maximum. There are no unbounded lists.
- [ ] Pagination is cursor based (the Relay connection shape is the common convention).
- [ ] Nested lists multiply. The cost model accounts for it.

## Cost and limits

- [ ] Queries are analysed before execution for depth and for a calculated cost, and are rejected above a limit.
- [ ] The rate limit is on cost, not on the number of HTTP requests. Shopify and GitHub both publish cost-based GraphQL limits.
- [ ] The response reports the cost and what is left, so callers can pace themselves.
- [ ] Aliases, fragments and batched operations are counted in the cost. A single request with a thousand aliased mutations is treated as a thousand.
- [ ] Each operation has a timeout, and resolvers pass the deadline to what they call.
- [ ] Request body size, query length and the number of operations per request are capped.
- [ ] For first-party clients, only persisted (registered) operations are accepted in production.
- [ ] Introspection is a decision: open for a public API, off or authenticated for a private one. It is never the only protection.
- [ ] Field suggestions in error messages are off where the schema is private.

## Resolvers

- [ ] Related data is batched and cached per request (the dataloader pattern), so a list of N does not make N calls.
- [ ] The per-request cache is never shared between callers.
- [ ] Resolvers contain no business rules. They call a service layer that also serves any other API.
- [ ] Calls to other services have timeouts and a retry budget.

## Authorisation

- [ ] Access is checked in the layer that loads each object, so every path through the graph is covered (OWASP API1).
- [ ] Field-level rules exist for sensitive fields, and a denied field returns null with an error, not the data. Such fields are nullable, because a null in a non-null field removes the whole parent.
- [ ] Arguments that select another user or tenant are checked against the caller.
- [ ] Mutations check the caller's right to perform the action (OWASP API5), and input types do not accept fields the caller should not set (OWASP API3).
- [ ] The node or global lookup field applies the same checks as the typed fields.

## Mutations

- [ ] Each mutation takes a single input object and returns a payload type.
- [ ] Expected failures (validation, conflict, not allowed) are modelled in the payload or as typed errors, so clients do not parse message strings.
- [ ] Mutations that must not repeat accept a client-supplied idempotency key.
- [ ] Updates that can conflict carry a version.
- [ ] Several mutations in one request run in order, and the client is told that they are not one transaction.

## Errors

- [ ] Errors carry a stable code in `extensions`. Messages are for people.
- [ ] Internal details (stack traces, SQL, upstream errors) never appear in responses.
- [ ] Partial success is expected: `data` and `errors` can both be present, and clients handle it.
- [ ] HTTP status codes follow the GraphQL over HTTP specification for the media type in use.

## Evolution

- [ ] The schema evolves without versions: add fields, deprecate old ones with `@deprecated(reason:)`, remove only when usage is gone.
- [ ] Field-level usage per client is measured.
- [ ] A schema check in CI compares each change with recorded operations and blocks breaking ones.
- [ ] Clients send a name and a version header, so a field's users can be found and contacted.
- [ ] Deprecations have a date and a migration note.

## Federation

- [ ] Each type and field has one owning team.
- [ ] The composed schema is checked in CI before any subgraph deploys.
- [ ] The gateway enforces limits and passes identity. Subgraphs still authorise.
- [ ] A failing subgraph degrades its own fields, not the whole response.
- [ ] Subgraphs are not reachable directly from outside.

## Subscriptions

- [ ] Connections are authenticated at start and re-checked during long sessions.
- [ ] Each event is authorised for each subscriber when it is delivered.
- [ ] There are limits on connections and subscriptions per caller.
- [ ] Clients reconnect with backoff and jitter, and can resume or refetch.

## Caching and transport

- [ ] Queries that are safe to cache can be sent as GET with a persisted identifier.
- [ ] Cache hints do not let one user's data be served to another.
- [ ] Cross-site request forgery is prevented: mutations are not accepted over GET, and simple content types are not accepted without a custom header.
- [ ] File uploads go to a separate endpoint or a signed URL.

## Sources

- GraphQL specification (September 2025 edition) and the current working draft.
- GraphQL over HTTP specification (GraphQL Foundation, draft).
- GraphQL Cursor Connections Specification (Relay).
- Shopify API limits (calculated query cost); GitHub GraphQL API rate and node limits.
- Apollo Federation documentation.
- OWASP GraphQL Cheat Sheet; OWASP API Security Top 10 (2023).
