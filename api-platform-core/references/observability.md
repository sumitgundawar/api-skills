# 13. Observability

You cannot retire, limit, price or debug what you cannot see. The questions to be able to answer are: who called what, on which version, how long did it take, and what did it cost.

## Checklist

- [ ] Every request gets an identifier at the edge. It is returned in a response header, included in error bodies, and present in every log line and trace for that request.
- [ ] One structured log line per request (a canonical log line) with: time, request identifier, consumer, credential type, method, route template, API version, cell or region, status, duration, bytes, rate limit state, idempotency key present, priority, and error type.
- [ ] The route is logged as a template (`/orders/{id}`), not the raw path, so it can be grouped.
- [ ] Traces follow W3C Trace Context (`traceparent`) across services. OpenTelemetry is the default instrumentation.
- [ ] RED metrics exist per route template and other bounded dimensions: request rate, errors and duration, plus saturation of the scarce resource. Useful bounded labels include API version, cell, outcome and priority.
- [ ] Raw consumer, tenant, request and object identifiers stay out of general-purpose metric labels. Put them in logs, traces or a usage store. Use them on a metric only when the active set is deliberately bounded, the cardinality limit is chosen and overflow is monitored.
- [ ] There are service level objectives per endpoint class, measured from the consumer's side, with an error budget that actually changes behaviour when it is spent.
- [ ] Automated traffic is labelled separately from human traffic: verified bot, declared bot, unknown automation, person.
- [ ] Usage per consumer and per API version is available from the usage pipeline on a dashboard. This is what makes retirement possible without turning each consumer into a metric series.
- [ ] Shed and rate-limited requests are counted separately from failures, and their latency is kept out of the success percentiles.
- [ ] Secrets, tokens and personal data are not logged. Query strings are scrubbed.
- [ ] Background jobs report against the same resource metrics as request handlers, so that a job starving the database is visible.
- [ ] Consumers can see their own request logs, errors and usage.

## What to alert on

- Burn rate of the error budget, not raw error counts.
- Saturation of the resource that fails first: connection pools, queue depth, worker utilisation.
- A rise in retries as a share of requests. This is an early sign of a retry storm.
- A new consumer, or a known consumer whose volume or pattern changes sharply.
- Alert routes are exercised. A dashboard nobody is paged from is not an operational control.

## The inventory problem

Undocumented endpoints are a security risk in their own right (OWASP API9, improper inventory management). Cloudflare's discovery found about 30 percent more API endpoints than its customers had declared. Compare the routes you observe in traffic with the routes in your contract, regularly.

## Sources

- Stripe, Fast and flexible observability with canonical log lines.
- W3C Trace Context. OpenTelemetry semantic conventions for HTTP (stable since v1.23, 2023).
- OpenTelemetry, Metric cardinality limits: https://opentelemetry.io/docs/specs/otel/metrics/sdk/
- Google SRE Book and SRE Workbook (service level objectives, error budgets).
- Cloudflare, 2024 API security and management report.
- OWASP API Security Top 10 2023, API9.
