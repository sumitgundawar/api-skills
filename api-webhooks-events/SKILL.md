---
name: api-webhooks-events
description: Reviews, designs and changes event-driven APIs. Covers sending webhooks (signing, retries, ordering, replay, endpoint management), receiving webhooks, message queues and streams, the outbox pattern, event schemas and their evolution, consumer idempotency, dead-letter handling and AsyncAPI or CloudEvents descriptions. Use when the project emits or consumes events, when the user mentions webhook, event, callback, queue, topic, Kafka, pub/sub, outbox, dead letter, at-least-once, CloudEvents or AsyncAPI, or when asked to make an integration safe against lost, duplicated or out-of-order events.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.1"
---

# Webhook and event APIs

An event API makes three promises that are easy to say and hard to keep: nothing is lost, duplicates are harmless, and order does not matter or is stated. Use Inventory → Assess → Report for a review. For a direct design, change or explanation, use only the relevant phases; the request already authorises its scoped work. If the `api-platform-core` skill is installed, use its workflow and general HTTP guidance, then this skill for the rules below.

## Ground rules

1. Never send a webhook to a real subscriber's endpoint, and never replay production events. Use a local receiver, and only after the user agrees.
2. Never change an event's schema, its meaning, or the conditions under which it is sent without the user's explicit go-ahead. Subscribers cannot be seen in your code.
3. Never send requests to production or to any shared environment. Assess by reading code and tests.
4. When you find a signing secret in code or logs, report the file and line, never the value.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose events, act on forged ones, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- Every event type: its name, its schema, when it is emitted and by which code path.
- How an event leaves the system: in the same transaction as the change, or afterwards.
- The delivery mechanism: HTTP webhooks, a broker, a stream.
- The guarantees claimed: at-least-once, ordering, retention, replay.
- Subscribers: who they are, how they register, how their endpoints are checked.
- Events you consume from others, and what you do with a duplicate.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can a change commit without its event, or an event go out for a change that rolled back?** Look for a database write followed by a separate publish.
2. **Can a receiver tell a forged event from a real one?** Look for a signature over the raw body with a timestamp.
3. **What does a consumer do with the same event twice or after a crash?** Look for a durable inbox and one transaction that applies the business effect and marks the event processed.
4. **Can a subscriber's address make your servers call your own network?** Look at how subscriber URLs are validated.
5. **What happens to an event that keeps failing?** Look for retries without end, or events dropped with no record.

## Phase 3: Report

Lead with anything that can lose an event, accept a forged one or reach an internal address. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start when the user asks for a change, or after they choose a finding. A new event type or optional field is a usually compatible candidate, not a guarantee: check strict decoders, unknown-event handling and representative consumers. A breaking change needs a new event version and the user's agreement.

- **Emit**: write the event to an outbox table in the same transaction as the change, and publish from the outbox.
- **Envelope**: a unique identifier, a type, a schema version, the time it happened, the subject, and the data.
- **Send**: signed with a per-subscriber secret and a timestamp; retried with exponential backoff and jitter for a stated period; then parked and visible.
- **Receive**: verify the signature and replay timestamp on the raw body; durably insert an inbox item before answering 2xx; then apply the business effect and mark the item processed in one local transaction. Reclaim stale work, bound retries, and park exhausted events with an alert, owner and replay runbook. Treat order as unreliable.
- **Replay**: an endpoint to list and resend events, so a subscriber can recover without asking.
- **Describe**: publish the event catalogue with schemas and examples.

## What this skill does not do

It does not choose a broker for you. It makes the events you send and receive safe to depend on.
