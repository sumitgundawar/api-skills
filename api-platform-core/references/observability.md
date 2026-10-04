# 13. Observability

You cannot retire, limit, price or debug what you cannot see. The questions to be able to answer are: who called what, on which version, how long did it take, and what did it cost.

## Checklist

- [ ] Every request gets an identifier at the edge. It is returned in a response header, included in error bodies, and present in every log line and trace for that request.
- [ ] One structured log line per request (a canonical log line) with: time, request identifier, consumer, credential type, method, route template, API version, status, duration, bytes, rate limit state, idempotency key present, priority, and error type.
- [ ] The route is logged as a template (`/orders/{id}`), not the raw path, so it can be grouped.
- [ ] Traces follow W3C Trace Context (`traceparent`) across services. OpenTelemetry is the default instrumentation.
- [ ] Metrics exist per endpoint and per consumer: rate, errors, duration percentiles, and saturation of the scarce resource.
- [ ] There are service level objectives per endpoint class, measured from the consumer's side, with an error budget that actually changes behaviour when it is spent.
- [ ] Automated traffic is labelled separately from human traffic: verified bot, declared bot, unknown automation, person.
- [ ] Usage per consumer and per API version is available on a dashboard. This is what makes retirement possible.
- [ ] Shed and rate-limited requests are counted separately from failures, and their latency is kept out of the success percentiles.
- [ ] Secrets, tokens and personal data are not logged. Query strings are scrubbed.
- [ ] Background jobs report against the same resource metrics as request handlers, so that a job starving the database is visible.
- [ ] Consumers can see their own request logs, errors and usage.

## What to alert on

- Burn rate of the error budget, not raw error counts.
- Saturation of the resource that fails first: connection pools, queue depth, worker utilisation.
- A rise in retries as a share of requests. This is an early sign of a retry storm.
- A new consumer, or a known consumer whose volume or pattern changes sharply.

## The inventory problem

Undocumented endpoints are a security risk in their own right (OWASP API9, improper inventory management). Cloudflare's discovery found about 30 percent more API endpoints than its customers had declared. Compare the routes you observe in traffic with the routes in your contract, regularly.

## Sources

- Stripe, Fast and flexible observability with canonical log lines.
- W3C Trace Context. OpenTelemetry semantic conventions for HTTP (stable since v1.23, 2023).
- Google SRE Book and SRE Workbook (service level objectives, error budgets).
- Cloudflare, 2024 API security and management report.
- OWASP API Security Top 10 2023, API9.
