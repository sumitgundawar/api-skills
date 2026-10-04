# 7. Pagination and queries

Every list grows. An endpoint that returns "all" of something will one day return too much.

## Checklist

- [ ] Every list endpoint is paginated from the first release. Adding pagination later is a breaking change, because the default page size changes what a client receives.
- [ ] Pagination uses cursors, not offsets. A cursor is an opaque string. The client must not rely on what is inside, so that you can change it. Base64 alone is not opaque: sign or encrypt the cursor and validate it on the way in, or clients will read and forge it.
- [ ] Consumers that need a whole data set have another route (an export job or a change feed). Cursors give no jump to page N and no parallel scan.
- [ ] The response gives the next cursor or a ready-made next URL, and a clear signal for the last page.
- [ ] There is a default page size and a maximum. Asking for more than the maximum returns the maximum, or a clear error. Document which.
- [ ] The sort order is stable and documented. Include a unique tie-breaker such as the identifier.
- [ ] Filters are named parameters with documented operators. Do not accept raw query language from clients.
- [ ] Total counts are not returned by default. Counting is expensive at scale. Offer an estimate or a separate endpoint if consumers need it.
- [ ] A cursor remains valid for a documented period and fails with a specific error after that.
- [ ] Consumers can ask for fewer fields, or for related objects to be included, so that they do not make one call per row.
- [ ] Expensive queries have their own limits: a maximum time range, a maximum depth, a cost budget.

## Why not offsets

Slack published its reasons for leaving offsets: the database reads and discards every row before the requested page, so deep pages are slow, and when rows are inserted while a client is paging, items repeat or are skipped. Its cursors are opaque, Base64-encoded pointers to the last item seen.

## Queries too large for a URL

- For complex read-only queries, HTTP now has the QUERY method (RFC 10008, June 2026). It is safe, idempotent and cacheable like GET, and carries a body like POST. OpenAPI 3.2 can describe it.
- Clients, proxies and caches will take years to support it. If you use it today, offer a POST fallback and advertise support with the `Accept-Query` response header.
- Do not use GET with a body. Intermediaries may drop it.

## Freshness

State whether a list is immediately or eventually consistent. Stripe's v2 API makes lists eventually consistent by default in exchange for lower latency, and says so.

## Sources

- Slack Engineering, Evolving API pagination at Slack.
- Stripe API v2 overview (list pagination and consistency).
- RFC 10008, The HTTP QUERY Method (June 2026).
- Google AIP-158 (pagination), AIP-160 (filtering), AIP-157 (partial responses).
