# Travel and booking API checklist

## Search and availability

- [ ] Search results are labelled as indicative and carry the time they were fetched.
- [ ] Caching is deliberate, with a lifetime per supplier and per route or property. Suppliers often cap the ratio of searches to bookings.
- [ ] A search that fans out to several suppliers has a deadline, returns partial results on time, and says which suppliers did not answer.
- [ ] Search is cursor paginated and has a cost-based limit. Price scraping is expected.
- [ ] Availability is checked again at quote or hold, never trusted from search.

## Quote and price

- [ ] A quote is a stored resource with an identifier, an itemised price and an expiry.
- [ ] Money is an integer in the smallest unit with a currency code. The currency charged and the currency shown are both recorded, with the rate.
- [ ] Taxes, fees and charges payable later (for example at the property) are itemised.
- [ ] If the price changes before booking, the API returns a specific error with the new quote. It never books at a different price silently.

## Hold and booking

- [ ] Inventory you own is reserved in one atomic conditional operation. Holds expire and are released.
- [ ] Booking accepts an idempotency key, and the key or a unique reference is passed to the supplier.
- [ ] The booking is a state machine that includes pending and failed-after-payment states.
- [ ] A supplier timeout is treated as unknown. A job queries the supplier and settles the state. Automatic retries cannot create a second booking.
- [ ] Payment and booking are ordered by a written rule (authorise, book, then capture is the usual one), with compensation for each failure point.
- [ ] Overbooking, where the business allows it, is an explicit, limited policy.
- [ ] Group bookings and multi-item itineraries have a defined answer for partial success.

## Changes and cancellations

- [ ] Rules (deadline, penalty, refund amount) are computed on the server and can be fetched before the caller commits.
- [ ] Cancel and change are idempotent, and a repeated cancel returns the same result.
- [ ] Changes made by the supplier (schedule change, relocation) arrive as events and are passed on to the customer and to integrators.
- [ ] Refunds follow the original payment method and cannot exceed what was paid.

## Time and place

- [ ] Local event times are stored as local time plus the place or zone identifier, not converted to UTC and back.
- [ ] Durations across daylight saving changes are computed with a zone database that is kept up to date.
- [ ] Dates for nights, days of hire and validity say whether they are inclusive.
- [ ] Places use standard codes where they exist (IATA airport and airline codes, ISO country codes).

## Supplier integrations

- [ ] Each supplier has its own timeout, retry budget, concurrency cap and circuit breaker. One slow supplier cannot stall search.
- [ ] Supplier responses are validated before use (OWASP API10).
- [ ] Supplier credentials are per environment and are never used from a test.
- [ ] Reconciliation compares your bookings with each supplier's records daily.
- [ ] Where you integrate airlines directly, the interface is usually IATA NDC. Check the version each airline supports.

## Traveller data

- [ ] Retrieval of a booking on your own API requires authentication or a long, unguessable token, and attempts are limited. A supplier's short locator plus a surname is the airline norm and you cannot change it, so do not make it the only check on your side.
- [ ] Passport, identity and payment details are collected only when needed, encrypted, masked in responses and deleted on a schedule.
- [ ] Data sent to suppliers is the minimum they need.
- [ ] Boarding passes, tickets and vouchers are not served from guessable addresses.

## Load and abuse

- [ ] Booking has reserved capacity. Search suggestions, maps and recommendations are shed first.
- [ ] On-sale moments and disruption days are load tested. A waiting room exists for on-sales.
- [ ] Holding inventory without paying is limited per customer, so stock cannot be locked up by automation.
- [ ] Loyalty points are treated as money: a ledger, idempotent changes and takeover defences.

## Sources

- IATA New Distribution Capability (NDC) standard.
- IANA Time Zone Database; RFC 9557 (timestamps with zone identifiers).
- OWASP API Security Top 10 (2023).
- Stripe API reference: Idempotent requests; separate authorisation and capture.
