# Webhook and event API checklist

## Producing events

- [ ] The event is recorded in the same transaction as the change it describes (an outbox table, or change data capture), and published from there. There is no dual write.
- [ ] Every event has a unique identifier that stays the same across retries.
- [ ] Every event has a type, a schema version, the time it happened, and the identifier of the thing it is about.
- [ ] Event types are named for what happened, in the past tense, and are stable (`order.paid`, not `updateOrder`).
- [ ] The choice between thin events (an identifier, fetch the rest) and full events (the data inside) is deliberate. Thin events avoid stale and sensitive payloads. Full events avoid a call back.
- [ ] Each resource carries a version or a sequence, so a consumer can tell which of two events is newer.
- [ ] The envelope follows a published convention where one fits (CloudEvents is the common one).

## Delivery guarantees

- [ ] The documentation states the guarantee: at-least-once, and whether order is preserved and within what scope.
- [ ] Ordering, where promised, is per key (per order, per account), not global.
- [ ] Retention and replay windows are stated.
- [ ] "Exactly once" is not promised to external subscribers. Consumers are told to deduplicate.

## Sending webhooks

- [ ] Each delivery is signed with a secret unique to the subscriber. The signature covers the stable event identifier, timestamp and raw body together, and receivers are told to reject timestamps outside a documented replay window.
- [ ] Secrets can be rotated with an overlap period, during which both are valid.
- [ ] The Standard Webhooks specification is followed, or your own scheme is documented as precisely.
- [ ] Failed deliveries are retried with exponential backoff and jitter over a stated period (hours to days), not immediately and not for ever.
- [ ] After the last retry, the event is kept and can be seen and resent. An endpoint that keeps failing is disabled and its owner is told.
- [ ] A delivery has a short timeout. A 2xx is the only success. Redirects are not followed. A 410 from the subscriber disables the endpoint.
- [ ] Deliveries to one subscriber are limited in concurrency, so a slow subscriber does not hold up the rest, and a backlog does not flood them on recovery.
- [ ] Subscriber URLs must be HTTPS, are resolved and checked against private, loopback, link-local and metadata addresses at send time, and are fetched from an isolated network path (OWASP API7, server-side request forgery). The connection goes to the address that was checked, so a second DNS answer cannot redirect it.
- [ ] Endpoint ownership is verified before events are sent.
- [ ] Subscribers choose which event types they receive.
- [ ] Subscribers can list recent deliveries with their status and response, and resend one.
- [ ] A test event can be sent on demand.

## Receiving webhooks

- [ ] The signature is verified against the raw request body, before parsing, with a constant-time comparison.
- [ ] The signed delivery timestamp is checked against a documented replay window. It is distinct from event occurrence time, and the window permits legitimate retry and operator replay.
- [ ] The raw event and a payload fingerprint are durably inserted into an inbox under a unique event identifier before 2xx. A duplicate with the same fingerprint is acknowledged; the same identifier with a different fingerprint is rejected and alerted as an integrity error.
- [ ] The asynchronous worker applies the business effect and marks the inbox item `PROCESSED` in one local transaction. A deduplication record cannot commit by itself and hide a lost effect.
- [ ] If an effect cannot share the inbox transaction, including another datastore or external system, the same transaction writes an outbox command. Delivery happens afterwards with a stable idempotency key, `UNKNOWN` state and reconciliation path.
- [ ] The inbox has explicit `RECEIVED`, `PROCESSING`, `PROCESSED` and dead-letter states or equivalent. Work is claimed with a lease so a stale attempt can be recovered.
- [ ] Processing retries are bounded. Exhausted items raise an alert, have a named owner and use a tested replay runbook.
- [ ] Order is not assumed. The handler fetches current state or compares a resource version or per-aggregate sequence.
- [ ] Unknown event types and unknown fields are ignored, not rejected.
- [ ] A reconciliation job catches events that never arrived.
- [ ] The receiving endpoint is rate limited and size limited, and reveals nothing in its error responses.

## Queues and streams

- [ ] Consumers are idempotent. Offsets or acknowledgements are committed after the work, so a crash means a repeat, not a loss.
- [ ] A message that keeps failing goes to a dead-letter queue after a bounded number of attempts, with an alert and an owner.
- [ ] One bad message cannot block a partition for ever.
- [ ] The partition key matches the ordering that consumers need.
- [ ] Consumer lag is monitored and has an alert.
- [ ] Producers handle a slow or full broker with a bounded buffer and a decision about what to do when it fills.
- [ ] Reprocessing from an earlier offset is safe and has been tried.

## Schema evolution

- [ ] Schemas are registered and checked for compatibility in CI.
- [ ] New optional fields and event types are treated as compatibility candidates, not automatically safe. Consumers have a tolerant-reader policy, and representative consumers are tested before release.
- [ ] A breaking change is a new event type or a new major version, published alongside the old one, with a retirement date.
- [ ] New enum values are announced, because they break strict consumers.
- [ ] Field meanings do not change under the same name.

## Documentation

- [ ] There is an event catalogue: each type, its schema, an example, when it fires and what the consumer should do.
- [ ] The description is machine readable (AsyncAPI, or webhooks in OpenAPI 3.1 and later).
- [ ] Retry schedule, signature scheme, source addresses if fixed, and timeouts are documented.

## Privacy and security

- [ ] Payloads contain the minimum. Sensitive data is fetched by the subscriber with its own credentials.
- [ ] Events for one tenant are never delivered to another's endpoint.
- [ ] Deleting a subscriber stops deliveries at once.
- [ ] Event logs that hold payloads are access controlled and expire.

## Sources

- Standard Webhooks specification (standardwebhooks.com).
- CloudEvents specification 1.0 (CNCF).
- AsyncAPI specification 3.1; OpenAPI Specification 3.1 and 3.2 (webhooks).
- Stripe documentation: Webhooks, best practices. GitHub documentation: Webhooks, validating deliveries.
- Chris Richardson, Transactional outbox pattern (microservices.io).
- OWASP API Security Top 10 (2023); OWASP Server-Side Request Forgery Prevention Cheat Sheet.
