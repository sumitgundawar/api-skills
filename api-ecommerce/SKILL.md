---
name: api-ecommerce
description: Reviews, designs and changes APIs for online shops and marketplaces. Covers catalogue, price and stock, carts, checkout, payments, orders, refunds, fulfilment, webhooks, flash-sale load, bot and scraper pressure, and checkout by AI shopping agents (UCP, ACP, AP2). Use when the project sells products or services online, when the user mentions cart, checkout, order, inventory, payment, refund, Shopify, Stripe, Magento or agentic commerce, or when asked to make a shop API safe against double charges, overselling or scraping.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.1"
---

# E-commerce APIs

In commerce the cost of a mistake is counted in money and in stock that does not exist. Use Inventory → Assess → Report for a review. For a direct design, change or explanation, use only the relevant phases; the request already authorises its scoped work. If the `api-platform-core` skill is installed, use its workflow and general HTTP guidance, then this skill for the domain rules below.

## Ground rules

1. Never change code that moves money, reserves stock or changes order state without the user's explicit go-ahead and a test that proves the new behaviour.
2. Keep card data away from your code wherever possible. Using the payment provider's hosted fields or tokens reduces PCI DSS scope. It does not remove it: PCI DSS 4.0.1 still has requirements for the scripts on a payment page. If you find raw card numbers in code, logs or a database, stop and report it first.
3. Prices and totals are calculated on the server. Never trust an amount sent by a client.
4. Never test against live payment credentials.
5. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance with seeded test accounts, and only after the user agrees.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose money, lose data, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

Map the domain objects and who owns each transition:

- Catalogue: product, variant, price, availability.
- Cart, and whether it survives across devices.
- Checkout: the step where totals, tax, shipping and payment are fixed.
- Payment: intent or authorisation, capture, refund, dispute.
- Order: the state machine and who may move it.
- Stock: where the count lives, and when it is reserved and released.
- Fulfilment: shipment, return.
- Events: which webhooks are sent and received, and from which providers.

Draw the order state machine before judging anything. If nobody can tell you the allowed transitions, that is the first finding.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can one click charge twice?** Follow a payment request through a timeout and a retry. Look for an idempotency key that reaches the payment provider.
2. **Can the last unit be sold twice?** Look for a read of stock followed by a separate write. It must be one atomic operation or a reservation.
3. **Can a client set its own price?** Look for amounts, discounts or totals accepted from the request body.
4. **Can a customer see another customer's order?** Read the order handlers and check that each one compares the order's owner with the caller. If there is no test for it, record that as a finding and propose the test in the report. Write it only in Phase 4, after the user agrees, on a branch.
5. **What happens when a payment webhook arrives twice, late, after a crash or never?** Look for a durable inbox, atomic payment effect plus processed marker, and a reconciliation job.

## Phase 3: Report

Lead with anything that can lose money, oversell or expose a customer's data. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start when the user asks for a change, or after they choose a finding. The list below is the target for new endpoints. On an existing endpoint, prefer a compatible migration (accept the key, add a cursor parameter beside the offset) and report a breaking form as needing a new version and the user's agreement.

Default design for the endpoints that matter:

- **Create checkout or order**: requires an idempotency key on new endpoints or in a new version. Scope it to tenant or principal plus operation, store a request fingerprint, and claim it atomically so concurrent duplicates cannot both execute. Recalculate every amount on the server, reserve stock with an expiry, and return the fixed totals.
- **Pay**: durably creates a `PENDING` payment attempt before calling the provider, with a uniqueness boundary, request fingerprint, provider-searchable business reference and provider key derived from the order and attempt number (for example `order_id:attempt`). Return that same stable attempt resource while it is pending or unknown. A retry reuses the key. Only a definitive decline starts a new attempt. After a timeout, retry downstream only if lookup conclusively proves no charge exists and the request is still valid; an inconclusive lookup remains `UNKNOWN` for manual reconciliation. Keep the internal record beyond the client retry and reconciliation horizon even if the provider forgets its key sooner. Treat the webhook or a server-side provider check, not the browser redirect, as the source of truth.
- **Update order**: optimistic concurrency with a version; state changes are explicit operations (`/cancel`, `/refund`, `/fulfil`) with rules.
- **Stock**: one atomic conditional decrement, or a reservation table with expiry; never read then write.
- **Webhooks in**: verify the signature and timestamp on the raw body; durably insert an inbox item before returning 2xx; apply the payment or order effect and mark the event processed in one transaction; bound retries and dead-letter exhausted events with an owner and replay runbook; reconcile daily.
- **Catalogue reads**: cacheable, cursor paginated, with a cost-based limit and separate, stricter limits for unidentified automation.

For peak events, add a queue or waiting room in front of checkout, shed non-essential calls first (recommendations, analytics), and load test the authenticated checkout path, not only anonymous browsing.

## Agentic checkout

If the shop should be usable by AI shopping agents, read the "Agents" section of the checklist. In short: publish a machine-readable profile, keep checkout a server-side state machine with an explicit hand-off to a person when one is needed, accept scoped payment tokens rather than card numbers, and verify the agent's identity.

## What this skill does not do

It does not give tax, consumer law or PCI compliance advice. It tells you where those reviews are needed.
