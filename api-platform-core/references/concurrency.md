# 6. Concurrency

Two writers will update the same record. Without a rule, the second silently erases the first. This is the lost update, and nobody finds it until a customer complains.

## Checklist

- [ ] Every updatable resource has a version that changes on every write, exposed as an `ETag` header and usually as a field too.
- [ ] Updates accept `If-Match` with the version the client last read. A mismatch returns 412 Precondition Failed and changes nothing.
- [ ] For resources where a lost update is costly, a write without `If-Match` returns 428 Precondition Required.
- [ ] Creates that must not duplicate use `If-None-Match: *` or an idempotency key.
- [ ] PATCH has one documented meaning. Use JSON Merge Patch (RFC 7396) for simple documents, or an explicit field mask listing the fields being changed. Do not treat missing fields as "set to null".
- [ ] State transitions are their own operations with their own rules, for example `POST /orders/{id}/cancel`. (Google's `:cancel` form is parsed as a path parameter by some routers and gateways.) Do not let a client PATCH a `status` field to any value.
- [ ] Counters and balances are changed with relative operations (`increment by 1`), not by read then write.
- [ ] The database enforces the invariant as well: a version column in the WHERE clause, a unique constraint, or a serialisable transaction.
- [ ] Bulk operations document whether they are all-or-nothing or may partly succeed, and return a result for each item.

## Reading your own writes

- Say in the contract how fresh a read is after a write. "Immediately consistent" and "eventually consistent" are both acceptable. Not saying is not.
- If lists are eventually consistent, tell clients not to verify a create by searching for it. Give them the identifier in the create response and let them fetch by identifier.
- Where a stale read is dangerous (permissions, balances), return a token from the write and accept it on the read to mean "at least this fresh".

## Tests to write

1. Two clients read version 7. Both write with `If-Match: "7"`. Expect one 200 and one 412.
2. A PATCH that names one field leaves every other field unchanged.
3. An invalid state transition is rejected with a specific error.

## Sources

- RFC 9110, HTTP Semantics, section 13 (conditional requests).
- RFC 6585, Additional HTTP Status Codes (428, 429).
- RFC 7396, JSON Merge Patch. RFC 6902, JSON Patch.
- Google AIP-134 (update and field masks), AIP-136 (custom methods), AIP-154 (ETags).
