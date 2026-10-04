---
name: api-marketplace
description: Reviews, designs and changes APIs for two-sided marketplaces and platforms where buyers pay sellers, hosts, drivers or freelancers. Covers seller onboarding and verification, listings, search and ranking, bookings and orders, split payments, holds, payouts, commissions, disputes, reviews, messaging between parties, and trust and safety. Use when the project connects two kinds of user and takes a fee, when the user mentions seller, vendor, host, payout, commission, escrow, split payment, connected account, listing, dispute or review, or when asked to make a marketplace API safe against lost payouts, fraud or circumvention.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Marketplace APIs

A marketplace holds other people's money and vouches for strangers to each other. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour. If `api-ecommerce` is installed, use it for cart, stock and checkout, and use this skill for everything that involves a second party.

## Ground rules

1. Never change code that moves money, releases a payout or changes a fee without the user's explicit go-ahead and a test that proves the new behaviour.
2. Money owed to a seller is tracked in a ledger with balanced entries. It is not a number on the seller's row.
3. Never test against live payment credentials or real seller accounts.
4. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance with seeded test accounts, and only after the user agrees.
5. When you find identity documents, bank details or card numbers in code or logs, report the file and line, never the value.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose money, lose data, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- The parties: buyer, seller, the platform, and any third (courier, agent).
- Onboarding: what is verified about a seller, by whom, and what they can do before it finishes.
- Listings, and who may change price, availability and content.
- The transaction: order or booking, its state machine, and the point at which money is taken.
- The money flow: who is the merchant of record, where funds sit, when the fee is taken, when the seller is paid.
- Disputes, refunds, cancellations and who bears the cost of each.
- Reviews and messaging between parties.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can a seller be paid twice, or for an order that was refunded?** Follow a payout through a retry and through a refund that arrives after it.
2. **Can a seller read or change another seller's listings, orders or payouts?** Check ownership on every seller endpoint.
3. **Can an unverified seller receive money?** Look for payout paths that do not check verification state.
4. **Can the two sides be enumerated or scraped?** Look for listing, profile and review endpoints with sequential identifiers and no limits.
5. **Can a review, a booking or an account be faked at scale?** Look for flows with no tie to a completed transaction and no protection from automation.

## Phase 3: Report

Lead with anything that can lose money, pay the wrong party or expose one party's data to the other. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Charge**: one buyer charge, with the split and the fee recorded as ledger entries in the same transaction as the order.
- **Payout**: a resource with a state machine and an idempotency key; computed from the ledger, never from a cached balance; blocked while verification, a dispute or a hold is open.
- **Refund after payout**: a defined rule for who pays, recorded as a negative balance or a reversal, never an edit.
- **Seller endpoints**: scoped to the seller from the credential. A seller's staff accounts have roles.
- **Buyer and seller contact**: through the platform, with personal details withheld until the transaction requires them.
- **Reviews**: tied to a completed transaction, one per party per transaction, with a moderation path.

## What this skill does not do

It does not give legal, tax or payments-licensing advice. It tells you where those reviews are needed.
