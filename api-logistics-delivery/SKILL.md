---
name: api-logistics-delivery
description: Reviews, designs and changes APIs for shipping, delivery, fleet, warehouse and supply chain software. Covers shipments, labels, rates, tracking events, routes and stops, driver and courier apps, proof of delivery, carrier integrations, address quality and location data. Use when the project moves physical goods or dispatches people, when the user mentions shipment, parcel, tracking, carrier, label, dispatch, route, driver, warehouse, pick, pack, delivery window or proof of delivery, or when asked to make a logistics API safe against lost events, duplicate labels or stale tracking.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Logistics and delivery APIs

A logistics API describes things happening in the physical world, reported late, twice and out of order by devices with poor signal. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. Never change code that creates labels, books collections, dispatches drivers or charges for shipping without the user's explicit go-ahead and a test.
2. Never call a live carrier account. Labels cost money and collections send a van.
3. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance, and only after the user agrees.
4. Location data about a person is personal data. Keep it out of logs and your own output.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose money, lose a shipment's history, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- The objects: order, shipment, parcel, label, route, stop, vehicle, driver, location, proof of delivery.
- The shipment state machine, and which events move it.
- Where events come from: scanners, driver apps, carriers, warehouse systems, and how they arrive.
- Carriers and their limits, costs and failure behaviour.
- Who reads tracking: the sender, the recipient, the public.
- Devices in the field, and what they do offline.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Does a retry buy a second label?** Follow label creation through a timeout.
2. **Can an old event overwrite a newer state?** Look for a status set from whichever event arrived last.
3. **Does an offline device lose or duplicate events when it reconnects?** Look for client-generated identifiers and deduplication.
4. **Can anyone read a delivery by guessing a tracking number?** Look at what the public tracking endpoint returns.
5. **Can one carrier's outage stop dispatch?** Look for carrier calls on the request path with no timeout or fallback.

## Phase 3: Report

Lead with anything that can lose money, lose track of goods or expose where a person lives or is. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Create shipment or label**: accepts an idempotency key and passes a unique reference to the carrier; validates the address first; returns a shipment with a state.
- **Events in**: each carries the time it happened, the time it was received and a client-generated identifier; stored append only; deduplicated; the current state is derived from them by event time.
- **Tracking out**: cursor paginated history plus a summary; webhooks signed and replayable; a public view that withholds names, full addresses and signatures.
- **Device sync**: batched uploads, safe to repeat, with a server acknowledgement per event.
- **Carrier calls**: off the request path where possible, with timeouts, budgets and a fallback carrier or a queued state.

## What this skill does not do

It does not give customs, dangerous goods or employment law advice. It tells you where those reviews are needed.
