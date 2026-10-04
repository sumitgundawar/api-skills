---
name: api-subscription-billing
description: Reviews, designs and changes APIs for subscriptions, usage metering, invoicing and entitlements. Covers plans and prices, plan changes and proration, trials, usage events, aggregation, invoices, credit notes, tax, failed payment recovery, entitlements and billing webhooks. Use when the project charges customers repeatedly or by usage, when the user mentions subscription, plan, price, metering, usage, invoice, proration, trial, dunning, entitlement, credits or seats, or when asked to make a billing API safe against double billing, lost usage or wrong invoices.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Subscription and billing APIs

A billing bug is the one kind of bug customers audit for you, months later, with interest. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. Never change code that prices, meters, invoices or charges without the user's explicit go-ahead and a test that proves the new amounts.
2. An issued invoice is never edited. It is corrected by a credit note or a new invoice.
3. Never test against live payment credentials. Use the provider's sandbox and its test clock, and only after the user agrees.
4. Never send requests to production or to any shared environment. Assess by reading code and tests.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can charge the wrong amount, lose revenue, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- The catalogue: product, plan, price, currency, billing period, and how old prices are kept.
- The subscription state machine: trial, active, past due, paused, cancelled, and what moves it.
- Usage: where an event is produced, how it reaches billing, and how it is aggregated.
- The invoice: what is on it, when it is finalised, who can change it before then.
- Payment collection and the recovery of failed payments.
- Entitlements: how the product learns what a customer may use.
- The billing provider, if any, and which side is the source of truth for each fact.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can a usage event be counted twice, or not at all?** Follow one event through a retry and through a crash of the sender.
2. **Can a job that runs twice bill twice?** Look at the renewal and invoicing jobs.
3. **Is proration right at the edges?** Look for month ends, leap days, time zones, and a change made twice in one period.
4. **Does access match what was paid for?** Look for entitlements checked in the client, or cached without a path to revoke.
5. **Can a customer change their own price?** Look for plan, price, quantity or coupon values trusted from the request.

## Phase 3: Report

Lead with anything that can charge a wrong amount or lose usage. Give the evidence, a worked example with numbers, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Usage events**: each has a unique identifier, a customer, a meter, a quantity and the time it happened; ingestion deduplicates on the identifier; late events have a stated cut-off.
- **Subscription changes**: explicit operations with an idempotency key and an effective time; a preview endpoint returns the resulting invoice lines before the caller commits.
- **Prices**: immutable once used. A new price is a new object, and existing subscribers stay on the old one until moved on purpose.
- **Invoices**: draft, then finalised and immutable; numbered without gaps where the law requires; totals reproducible from stored lines.
- **Entitlements**: served by one endpoint from one source, with an event when they change.
- **Webhooks from the provider**: verified, deduplicated, processed in a way that tolerates any order, and reconciled daily.

## What this skill does not do

It does not give tax, accounting or revenue recognition advice. It tells you where those reviews are needed.
