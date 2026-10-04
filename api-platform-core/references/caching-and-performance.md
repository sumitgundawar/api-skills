# 12. Caching and performance

The fastest request is the one you do not serve. The second fastest is the one that returns "not modified".

## Checklist

- [ ] Every GET response has an explicit `Cache-Control`. "No header" is not a policy.
- [ ] Cacheable responses carry an `ETag` or `Last-Modified`, and the server honours `If-None-Match` with 304.
- [ ] `Vary` lists every request header that changes the response, including `Accept` if you serve more than one representation.
- [ ] Responses that depend on the caller are `private` or are keyed on the credential. A shared cache must never serve one tenant's data to another. Note that a shared cache will not store a response to a request with an `Authorization` header unless the response explicitly allows it (RFC 9111, section 3.5).
- [ ] Shared caches (CDN, gateway) have their own directives where they differ from the browser's (`CDN-Cache-Control`, RFC 9213).
- [ ] Responses are compressed. Brotli and gzip are universal. Zstandard is supported by current Chrome and Firefox.
- [ ] Clients reuse connections. HTTP/2 or HTTP/3 is enabled at the edge.
- [ ] Payloads are bounded. Lists are paginated, large fields are opt-in, and consumers can request fewer fields.
- [ ] There is a way to fetch related data in one call (expansion, includes, a batch endpoint) so consumers do not issue one call per row.
- [ ] Latency targets are stated as percentiles (p50, p99), per endpoint, and measured from the consumer's side.
- [ ] Slow operations are asynchronous: return 202 with an operation resource the client can poll, or deliver a result by event.
- [ ] Large uploads go directly to object storage with a pre-signed URL, and can resume.

## Tail latency

- At scale the slowest one percent decides the user experience, because one page makes many calls.
- Hedged requests: send a second copy of a read to another replica once the first has been outstanding longer than the usual 95th percentile. In one Google benchmark, hedging after 10 ms cut 99.9th percentile latency from 1,800 ms to 74 ms for about 2 percent more requests. Only safe for idempotent reads.
- Set timeouts from measured percentiles, not round numbers.
- Protect caches from stampedes: a short lock or "stale while revalidate" so one request refreshes an expired entry while others get the stale copy.
- A cache that the system cannot run without is a dependency, not an optimisation. Test starting cold.

## Asynchronous work

- For anything that can take more than a few seconds, return 202 and a status resource with `state`, `progress`, `result` or `error`, and an expiry.
- Make the start call idempotent, so a retry does not start the job twice.
- Offer cancellation.

## Sources

- RFC 9111, HTTP Caching. RFC 9110, HTTP Semantics. RFC 9213, Targeted HTTP Cache Control. RFC 5861, stale-while-revalidate.
- Dean and Barroso, The Tail at Scale. Communications of the ACM, 2013.
- Google AIP-151, Long-running operations.
- IETF draft-ietf-httpbis-resumable-upload (draft 12, July 2026; not yet an RFC).
