# 8. Errors

An error response is part of the contract and, for an automated caller, it is the documentation. A person will go and read the docs. An agent will act on what the error says.

## Checklist

- [ ] One error format across the whole API. Use Problem Details for HTTP APIs (RFC 9457): `type`, `title`, `status`, `detail`, `instance`, with media type `application/problem+json`.
- [ ] `type` is a stable identifier that clients can branch on. Never make clients parse `detail`.
- [ ] `detail` says what was wrong and what to do next, in plain words: which field, which permission, which limit.
- [ ] Validation errors list every invalid field in one response, with a pointer to each.
- [ ] Every error says whether retrying can help. Use the status code for the class and a field or header for the specifics.
- [ ] 429 and 503 include `Retry-After`.
- [ ] Errors carry a request identifier that also appears in your logs.
- [ ] Status codes mean what HTTP says they mean. 400 for malformed, 401 for unauthenticated, 403 for forbidden, 404 for not found, 409 for conflict, 410 for gone, 412 for failed precondition, 422 for semantically invalid, 428 for missing precondition, 429 for too many requests, 5xx for your fault.
- [ ] On a REST API a 200 response never contains an error. Batch endpoints return a per-item status and an overall status that reflects partial failure. (GraphQL is the exception by design: it returns 200 with an `errors` array. Document that, and give each error a stable code in `extensions`.)
- [ ] Errors never leak stack traces, SQL, internal host names or other tenants' data.
- [ ] Error types are documented and versioned like the rest of the contract. Changing which error a case returns is a breaking change.

## A good error for an automated caller

```
HTTP/1.1 403 Forbidden
WWW-Authenticate: Bearer error="insufficient_scope", scope="refunds:write"
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/missing-scope",
  "title": "Missing scope",
  "status": 403,
  "detail": "This token lacks refunds:write. Ask the account owner to grant it. Do not retry until it is granted.",
  "required_scope": "refunds:write",
  "instance": "/requests/req_8f2k1"
}
```

Points to copy:

- `title` describes the type of problem and is the same for every occurrence. The specifics go in `detail`.
- The remedy is also machine-readable: an extension member (`required_scope`) and the standard OAuth signal in `WWW-Authenticate` (RFC 6750). A client never has to parse `detail`.
- `type` is an absolute URI.
- A rejection that happens before the operation starts (authentication, permission, validation) should not be stored against the idempotency key, so the same key can be used once the cause is fixed.

A caller that receives only `{"message":"Something went wrong"}` has nothing to act on, and many will simply retry, which adds load without any chance of success.

## Retry guidance to publish

- Safe to retry as is: 408, 429, 502, 503, 504, and network failures, provided the request is idempotent or carries an idempotency key. A 425 is retried outside TLS early data.
- An error never tells a caller to grant itself more access. It names what is missing and who can grant it.
- Do not retry: 400, 401, 403, 404, 410, 412, 422, until something changes.
- 409 has two meanings, so give them distinct problem types. A conflict of state (the order is already cancelled): do not retry. A request with the same idempotency key still executing: retry after a backoff.
- Always back off with jitter and respect `Retry-After`.

## Sources

- RFC 9457, Problem Details for HTTP APIs (2023).
- RFC 9110, HTTP Semantics (status codes, Retry-After).
- Google AIP-193, Errors.
- Anthropic Engineering, Writing effective tools for agents (error messages that steer).
