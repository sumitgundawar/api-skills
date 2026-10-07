# 9. Events and webhooks

Use events when consumers need to know that something happened without polling. Treat the event stream as a second public contract with the same care as the request API.

## Checklist for sending

- [ ] Every event has a unique identifier, a type, a creation time and a version.
- [ ] Delivery is at least once. Say so, and tell receivers to deduplicate on the event identifier.
- [ ] Ordering is not guaranteed unless you can truly guarantee it. Say so. Give receivers what they need to cope: a sequence number per object, or a thin event that makes them fetch current state.
- [ ] Payloads are signed. Sign the identifier, the timestamp and the raw body together, and publish how to verify. The Standard Webhooks specification (`webhook-id`, `webhook-timestamp`, `webhook-signature`) is a ready-made convention.
- [ ] Receivers reject a timestamp that is too old, to prevent replay.
- [ ] Signing secrets can be rotated with two valid at once.
- [ ] Failed deliveries are retried with exponential backoff and jitter over a published period. Stripe retries for up to three days in live mode.
- [ ] An endpoint that keeps failing is disabled, and the owner is told.
- [ ] There is a way to list and replay past events, so a receiver that was down can catch up.
- [ ] Sending is decoupled from the request that caused it. Write the event in the same transaction as the state change (the outbox pattern) and deliver it from a separate process.
- [ ] Destination URLs are validated to prevent requests to internal addresses (server-side request forgery, OWASP API7).
- [ ] Event schemas are documented, for example in AsyncAPI, and evolve under the same compatibility rules as the request API.

## Thin or full payloads

- **Full (snapshot) events** carry the object as it was. Convenient, but a late event can overwrite newer state, and the payload is tied to an API version.
- **Thin events** carry the type and the identifier only. The receiver fetches the current object. This removes ordering problems and version coupling, at the cost of one extra call. Stripe's v2 API emits thin events for this reason.
- If you send full events, include the object's version so receivers can discard stale ones.

## Checklist for receiving

- [ ] Verify the signature against the raw body before parsing.
- [ ] Check the signed delivery timestamp against a documented replay window before accepting the event. Keep it distinct from the event's occurrence time, and make the window compatible with legitimate provider retries and operator-initiated replay.
- [ ] Durably insert the raw event and its payload fingerprint into an inbox with a unique event identifier before returning 2xx. A duplicate with the same fingerprint is acknowledged; the same identifier with a different fingerprint is rejected and alerted as an integrity error.
- [ ] A worker applies the business effect and marks the inbox item processed in the same local transaction. A crash can cause another attempt, but can never leave a "processed" marker without the effect.
- [ ] If any effect cannot share the inbox transaction, including a write to another datastore or an external call, that transaction writes an outbox command instead. Deliver the command afterwards with its own stable idempotency key, `UNKNOWN` state and reconciliation path.
- [ ] Stale `PROCESSING` records are reclaimed with a lease. Retries are bounded; exhausted records go to a dead-letter state with an alert, an owner and a tested replay runbook.
- [ ] Do not assume order. Fetch current state or compare a resource version or per-aggregate sequence when order matters.
- [ ] Reconcile periodically by listing, in case an event never arrived.

The fast acknowledgement boundary is durable storage, not completed business work. If storing the inbox item and applying the effect happen in different transactions, keep distinct `RECEIVED`, `PROCESSING` and `PROCESSED` states. The atomic invariant is between the business effect and the transition to `PROCESSED`.

## Beyond webhooks

At high volume, offer delivery to a queue or event bus as well as HTTP callbacks. CloudEvents (a CNCF graduated project since January 2024) gives a common envelope across brokers.

## Sources

- Stripe docs: Webhooks; Event destinations; Migrate from snapshot to thin events.
- Standard Webhooks: https://www.standardwebhooks.com/
- AsyncAPI 3.1 (January 2026). CloudEvents 1.0.
- OWASP API Security Top 10 2023, API7 Server Side Request Forgery.
