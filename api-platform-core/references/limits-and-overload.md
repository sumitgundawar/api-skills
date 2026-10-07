# 11. Limits and overload

Every system has a ceiling. The design question is who hears "no", and how early.

## Checklist: limits

- [ ] Every endpoint has a limit. Unlimited endpoints are the ones that take you down (OWASP API4, unrestricted resource consumption).
- [ ] Limits are per identity (account, key, token), not only per IP address.
- [ ] There is a limit on requests in flight per caller, not only on requests per second.
- [ ] Expensive operations cost more than cheap ones. Meter by cost (points, query complexity, compute time, tokens), not by request count alone.
- [ ] Reject a caller that exceeded its own allocation with 429. Include `Retry-After` only when the server has a credible estimate, and tell the caller how much quota remains.
- [ ] Limits are documented per plan, and a consumer can see its own usage.
- [ ] Limiters are launched in observe-only mode first and have a kill switch. A fairness limiter fails open if the limiter itself breaks. A limiter that is the only protection for a fragile backend, a login endpoint or a paid downstream call fails closed.
- [ ] Request size, page size, batch size, query depth and upload size all have maximums.

## Checklist: overload

- [ ] Every outbound call has a timeout shorter than the caller's own deadline.
- [ ] Deadlines are passed down the call chain. A service does not work on a request its caller has abandoned.
- [ ] Retry ownership is explicit. Prefer one retrying layer on a synchronous call path; independent asynchronous boundaries share one end-to-end attempt budget rather than multiplying retries invisibly.
- [ ] Each client has a retry budget: retries are a bounded fraction of requests, for example 10 percent. A timeout without a budget makes overload worse, because every timeout becomes a retry.
- [ ] The retry budget is enforced by a mechanism, such as a retry token bucket replenished by original or successful calls, or a rolling `retries / originals` limit.
- [ ] Circuit breakers, concurrency limits and retry budgets are separate controls. A breaker stops calls to an unhealthy dependency; a concurrency limit caps active work; a retry budget caps extra attempts.
- [ ] Retries back off exponentially with jitter.
- [ ] Concurrency limits adapt to measured latency where the platform supports it, instead of a fixed number.
- [ ] When differentiated shedding is needed, the service assigns priority from authenticated operation and policy, then propagates it. A caller may lower its own priority (a prefetch, a background sync) and may never raise it. Each class has a quota, or everything becomes critical. Do not name the header `Priority`: RFC 9218 already defines it for another purpose.
- [ ] Under pressure, the lowest priority is shed first.
- [ ] A share of capacity is reserved for the most critical operations.
- [ ] Service-wide or shared-dependency load shedding returns 503 quickly and cheaply, before doing any work. Do not disguise shared saturation as a caller-specific 429.
- [ ] Background jobs that share a database, queue or provider with request handlers have their own concurrency and retry budgets and are paced against the resource that can actually fail.
- [ ] When simpler per-tenant rate, concurrency and fair-queue controls are insufficient, isolate tenants with pools, shards or cells so one tenant cannot exhaust everyone's capacity.

## The four limiters (Stripe)

1. **Request rate limiter**: N requests a second per user, with a short burst. Returns 429.
2. **Concurrent request limiter**: a cap on requests in flight per user. Protects expensive endpoints. Returns 429.
3. **Fleet usage load shedder**: reserves a fraction of capacity for critical methods. Non-critical requests over the allocation get 503.
4. **Worker utilisation load shedder**: the last resort when workers are saturated. Sheds in order: test mode traffic, GETs, POSTs. Critical methods last.

## Retry arithmetic (Google SRE)

If three layers each make up to four attempts, one user action can produce 64 attempts at the bottom layer (4 x 4 x 4). A retry budget of 10 percent caps each layer at about 1.1 times its normal load, so three layers compound to about 1.33 times (1.1 x 1.1 x 1.1) instead of 64. Retrying at one layer only keeps it at 1.1.

A metastable failure is one that continues after its trigger is gone, because the extra load from retries is enough to keep the system saturated. Recovery needs load to be removed, not capacity to be restored. A study at OSDI 2022 found that retries were the sustaining effect in more than half of the cases it examined.

Little's Law gives the capacity intuition: average work in flight is approximately arrival rate multiplied by average latency (`N = λW`). If latency grows from 100 ms to 2 s at the same 1,000 requests per second, average in-flight work grows from about 100 to 2,000. A rate limit alone does not stop that queue; deadlines and concurrency limits bound the waiting work.

## Priority shedding (Netflix)

Netflix lets each service assign requests one of four priorities (critical, degraded, best effort, bulk) and sheds from the bottom as CPU pressure rises. In the surge of retries that followed a real outage, prefetch requests fell to as low as 20 percent availability while playback requests started by a person stayed above 99.4 percent.

## Telling the client

The IETF draft `RateLimit` and `RateLimit-Policy` headers (draft-ietf-httpapi-ratelimit-headers-11, May 2026) are not yet an RFC. If you adopt them, be ready for the syntax to change. `Retry-After` is standard today.

On a normal response:

```
RateLimit-Policy: "default";q=100;w=60
RateLimit: "default";r=50;t=30
```

On a rejection:

```
HTTP/1.1 429 Too Many Requests
RateLimit: "default";r=0;t=30
Retry-After: 30
```

When the estimate is credible, vary `Retry-After` per response (a base plus a random spread). A fixed value sent to every rejected caller turns one spike into a second spike. When recovery time is unknown, omit the header and document exponential backoff with jitter. For callers you do not own, cap requests in flight per caller and reject before doing any work, so that a rejection costs far less than serving the request.

## Blast radius

Two different patterns. Do not mix them.

- **Cells**: full failure boundaries. Each owns its compute, database, cache, queues and workers, including webhook workers. A customer has one authoritative home cell; that cell belongs to a region. A small, replicated placement directory stores `{partition, home_cell, placement_epoch}`. Directory writes and placement moves are strongly consistent. Routers forward the epoch. After cutover, the old cell rejects or redirects every request carrying the stale epoch, including reads, so it cannot serve indefinitely stale state. Cached mappings may serve an unchanged placement only while their placement lease and epoch can be validated; an expired or unverifiable mapping fails closed and refreshes from the directory. New placements and moves fail closed when the directory cannot be updated.
- Move a partition through an explicit state machine: copy, validate, fence the old placement, atomically advance the directory epoch, cut over, drain and either complete or roll back. Avoid unreconciled dual writes. Size and rebalance cells by measured workload, skew, admission thresholds and failure headroom, not equal tenant counts. Define cross-cell operations and fan-out explicitly.
- Regional disaster recovery is separate from ordinary cell routing. State replication and backup strategy, RPO, RTO, single-writer fencing, and whether failover is automatic or operator-driven. A router must not send a customer to another region merely because the home cell is unavailable.
- Identity providers, payment providers and control planes may remain shared dependencies. Enumerate which can degrade without taking every cell down, and test them rather than claiming complete isolation.
- **Shards** partition data. A cell promotes a shard into an operational boundary around all resources needed to serve that slice.
- **Shuffle sharding**: for stateless, interchangeable workers. Give each customer a small combination of them. With 8 workers and 2 per customer there are 28 possible pairs. If one customer takes down its pair, then of the 28 pairs, 15 are untouched, 12 lose one of their two workers, and 1 (the same pair) loses both.
- Splitting a shared dependency by function (moving one service's data out of a cluster that everything reads) is a third, simpler form of isolation, and often the first one to do.

## Sources

- Stripe, Scaling your API with rate limiters (2017).
- Google SRE Book, chapters 21 (Handling Overload) and 22 (Addressing Cascading Failures).
- Huang et al. Metastable Failures in the Wild. OSDI 2022.
- Netflix Tech Blog, Enhancing Netflix reliability with service-level prioritized load shedding (2024).
- AWS Builders' Library: Using load shedding to avoid overload; Timeouts, retries and backoff with jitter; Workload isolation using shuffle sharding. AWS Well-Architected REL10-BP03.
- AWS Well-Architected, Reducing the Scope of Impact with Cell-Based Architecture: https://docs.aws.amazon.com/wellarchitected/latest/reducing-scope-of-impact-with-cell-based-architecture/what-is-a-cell-based-architecture.html
- Rate limit documentation: GitHub REST API, Shopify, Canvas LMS, Bluesky.
- OWASP API Security Top 10 2023, API4.
