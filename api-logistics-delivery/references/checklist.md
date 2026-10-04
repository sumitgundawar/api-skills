# Logistics and delivery API checklist

## Shipments and labels

- [ ] Creating a shipment or a label accepts an idempotency key, and a unique reference is sent to the carrier, so a retry cannot buy a second label.
- [ ] Rates are quoted as a resource with an expiry, and the label is bought against a quote.
- [ ] Weights and dimensions carry units. Money carries a currency.
- [ ] Voiding a label is an explicit, idempotent operation with a deadline.
- [ ] Bulk label creation is asynchronous with a result per item.
- [ ] A multi-parcel shipment has a defined answer for partial failure.

## Addresses and places

- [ ] Addresses are validated and normalised before a label is bought, and the original input is kept.
- [ ] Address fields follow the destination country's format. No assumption that every address has a postcode or a state.
- [ ] Coordinates are stored with a stated reference system and precision. Geocoding results are cached and their source recorded.
- [ ] Delivery instructions and safe-place notes are free text that may contain personal data, and are handled as such.

## Events and state

- [ ] Every event has an occurred-at time (from the device), a received-at time (from the server), a source and a unique identifier.
- [ ] Events are append only. The shipment's state is derived by an explicit state machine over all events, ordered by occurred-at within a tolerance and by received-at beyond it. Allowed backward moves (delivered then returned, a scan made in error) are listed.
- [ ] Duplicate events are detected on the identifier. Carriers and scanners deliver at least once.
- [ ] Device clocks are not trusted blindly. Large skews are flagged.
- [ ] Carrier status codes are mapped to your own small set of states, and the raw code is kept.
- [ ] Exceptions (failed delivery, damage, return to sender) are states with reasons, not free text.

## Tracking and notifications

- [ ] The public tracking view needs an unguessable token, or it returns only coarse status. Names, full addresses, signatures and photos require authentication.
- [ ] Tracking lookups are rate limited, since tracking numbers are often sequential.
- [ ] Outgoing webhooks are signed, retried with backoff, ordered per shipment or carry a sequence, and replayable.
- [ ] Polling is discouraged by offering webhooks and by cacheable responses with ETags.
- [ ] Estimated delivery times carry the time they were computed and a window, not a single instant.

## Field devices

- [ ] The driver or scanner app works offline, queues events with client-generated identifiers, and uploads in batches that are safe to repeat.
- [ ] The server acknowledges each event, so the device knows what it can drop.
- [ ] Proof of delivery (signature, photo, location) is uploaded resumably, linked to the stop, and access controlled.
- [ ] A reconnecting fleet does not arrive at once: reconnects carry jitter and backoff.
- [ ] Old app versions keep working, and there is a minimum version and a way to enforce it.
- [ ] A lost or stolen device can be revoked.

## Routes and dispatch

- [ ] Assigning a job is atomic, so two drivers cannot accept the same stop.
- [ ] Route optimisation is an asynchronous job with a status, since it can run for minutes.
- [ ] Re-planning does not lose stops already completed.
- [ ] Live location updates are sampled and batched, with a cost-based limit.

## Carrier integrations

- [ ] Each carrier has its own timeout, retry budget, concurrency cap and circuit breaker.
- [ ] Carrier responses are validated before use (OWASP API10), and carrier webhooks are verified.
- [ ] Carrier credentials are per customer where customers bring their own accounts, and are stored encrypted.
- [ ] Charges are reconciled against carrier invoices.
- [ ] Electronic data interchange and partner files are parsed defensively and processed idempotently.

## Privacy and safety

- [ ] Recipient contact details and location history are kept only as long as needed and are deleted on a schedule.
- [ ] A driver's live location is visible only to those who need it, and only while on a job.
- [ ] Customs data and declared contents are access controlled.

## Load

- [ ] Peak season is load tested. Label creation and scanning have reserved capacity. Reports and exports are shed first.
- [ ] Warehouse cut-off times produce a predictable burst, and the system is sized for it.

## Sources

- GS1 standards: SSCC, GTIN and EPCIS for event data.
- Universal Postal Union addressing standard S42; ISO 3166 country codes.
- OWASP API Security Top 10 (2023).
- Standard Webhooks specification.
