---
name: api-ecommerce
description: Reviews, designs and changes APIs for online shops and marketplaces. Covers catalogue, price and stock, carts, checkout, payments, orders, refunds, fulfilment, webhooks, flash-sale load, bot and scraper pressure, and checkout by AI shopping agents (UCP, ACP, AP2). Use when the project sells products or services online, when the user mentions cart, checkout, order, inventory, payment, refund, Shopify, Stripe, Magento or agentic commerce, or when asked to make a shop API safe against double charges, overselling or scraping.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# E-commerce APIs

In commerce the cost of a mistake is counted in money and in stock that does not exist. Work in the same four phases as any API review: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. Never change code that moves money, reserves stock or changes order state without the user's explicit go-ahead and a test that proves the new behaviour.
2. Keep card data away from your code wherever possible. Using the payment provider's hosted fields or tokens reduces PCI DSS scope. It does not remove it: PCI DSS 4.0.1 still has requirements for the scripts on a payment page. If you find raw card numbers in code, logs or a database, stop and report it first.
3. Prices and totals are calculated on the server. Never trust an amount sent by a client.
4. Never test against live payment credentials.
5. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance with seeded test accounts, and only after the user agrees.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. If it reads live credentials, or points at any host that is not local or a named sandbox, do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format) keep that protocol's own errors, paging and status codes. Report a deviation from the protocol, not from this checklist.

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
5. **What happens when a payment webhook arrives twice, late or never?** Look for deduplication on the event identifier and a reconciliation job.

## Phase 3: Report

Lead with anything that can lose money, oversell or expose a customer's data. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form (accept the key, add a cursor parameter beside the offset) and report the required form as a breaking change that needs a new version and the user's agreement.

Default design for the endpoints that matter:

- **Create checkout or order**: accepts an idempotency key, and requires it on new endpoints or in a new version; recalculates every amount on the server; reserves stock with an expiry; returns the fixed totals.
- **Pay**: passes the payment provider an idempotency key derived from the order and the payment attempt number (for example `order_id:attempt`). Persist the attempt number before calling the provider. A retry of the same attempt reuses the key. Only a definitive decline starts a new attempt with a new key, because some providers replay the first result, including a decline. A timeout never does, or the customer is charged twice. Stores the provider's identifiers. Treats the webhook, not the redirect, as the source of truth.
- **Update order**: optimistic concurrency with a version; state changes are explicit operations (`/cancel`, `/refund`, `/fulfil`) with rules.
- **Stock**: one atomic conditional decrement, or a reservation table with expiry; never read then write.
- **Webhooks in**: verify signature on the raw body, store the event identifier, return 2xx fast, process asynchronously, reconcile daily.
- **Catalogue reads**: cacheable, cursor paginated, with a cost-based limit and separate, stricter limits for unidentified automation.

For peak events, add a queue or waiting room in front of checkout, shed non-essential calls first (recommendations, analytics), and load test the authenticated checkout path, not only anonymous browsing.

## Agentic checkout

If the shop should be usable by AI shopping agents, read the "Agents" section of the checklist. In short: publish a machine-readable profile, keep checkout a server-side state machine with an explicit hand-off to a person when one is needed, accept scoped payment tokens rather than card numbers, and verify the agent's identity.

## What this skill does not do

It does not give tax, consumer law or PCI compliance advice. It tells you where those reviews are needed.
