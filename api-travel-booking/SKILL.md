---
name: api-travel-booking
description: Reviews, designs and changes APIs for travel, hospitality, ticketing and any reservation of scarce, dated inventory. Covers search and availability, price quotes, holds, booking, payment, changes and cancellations, supplier integrations, time zones and currencies. Use when the project sells flights, rooms, seats, tables, tickets, rentals or appointments, when the user mentions booking, reservation, availability, fare, hold, PNR, itinerary, check-in, supplier or channel manager, or when asked to make a booking API safe against double booking, stale prices or lost reservations.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Travel and booking APIs

A booking API sells something that exists once, for one date, at a price that changes while the customer is reading it. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. Never change code that creates, changes or cancels a booking, or that takes payment, without the user's explicit go-ahead and a test that proves the new behaviour.
2. Never make real bookings. Use the supplier's test environment, and only after the user agrees.
3. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance, and only after the user agrees.
4. A time without a place is a bug. Departure, check-in and event times are local to where they happen.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose money, lose a booking, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- What is sold, and who holds the real inventory: you, or a supplier.
- The path: search, quote, hold, book, pay, ticket or confirm, change, cancel.
- Suppliers and channels, their limits, their timeouts and how often their answers are cached.
- The booking state machine, including "requested but not confirmed by the supplier".
- Where prices, taxes, fees and currencies are fixed.
- Traveller data collected, including passport and payment details.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can the same seat, room or slot be sold twice?** Look for an availability read followed by a separate write.
2. **Can a customer pay and end up with no booking, or a booking with no payment?** Follow the path through a supplier timeout after payment.
3. **Can the price change between quote and charge without the customer agreeing?** Look for a booking that re-prices silently.
4. **Is a retried booking a second booking?** Look for an idempotency key that reaches the supplier.
5. **Can a booking be read with only a short reference?** Look for retrieval by a guessable code and a surname.

## Phase 3: Report

Lead with anything that can double book, charge without booking or expose a traveller. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Search**: cacheable and cheap, clearly marked as indicative, with a freshness time. Cost-based limits, because one search can fan out to many suppliers.
- **Quote**: a resource with an identifier, a fixed price and an expiry.
- **Hold**: an atomic reservation with an expiry that is released on timeout.
- **Book**: takes the quote identifier and an idempotency key; fails with a specific error if the price or availability changed; returns a booking with a state.
- **Supplier unknown**: a timeout leaves the booking pending and a background job resolves it. The customer is told the truth.
- **Change and cancel**: explicit operations that return the cost before the caller commits.

## What this skill does not do

It does not give consumer law, package travel or aviation regulatory advice. It tells you where those reviews are needed.
