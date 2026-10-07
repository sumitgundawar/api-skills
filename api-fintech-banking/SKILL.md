---
name: api-fintech-banking
description: Reviews, designs and changes APIs for banking, payments, wallets, lending and other financial products. Covers ledgers, balances, transfers, payment initiation, open banking, strong customer authentication, reconciliation, fraud controls, audit and regulatory reporting. Use when the project moves or records money, when the user mentions ledger, balance, transfer, payout, account, IBAN, open banking, PSD2, FAPI, ISO 20022, KYC or AML, or when asked to make a money API safe against double spending, lost transfers or unbalanced books.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.1"
---

# Fintech and banking APIs

In a financial API every write is a claim about money that someone will audit. Use Inventory → Assess → Report for a review. For a direct design, change or explanation, use only the relevant phases; the request already authorises its scoped work. If the `api-platform-core` skill is installed, use its workflow and general HTTP guidance, then this skill for the domain rules below.

## Ground rules

1. Never change code that moves money, changes a balance or posts to a ledger without the user's explicit go-ahead and a test that proves the new behaviour.
2. Money is never a floating point number. It is an integer in the smallest unit, or a decimal type, with a currency code.
3. Ledger entries are never updated or deleted. A mistake is corrected with a new, opposite entry.
4. Never test against live credentials, live accounts or a production payment scheme.
5. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance with seeded test accounts, and only after the user agrees.
6. When you find an account number, card number or credential in code or logs, report the file and line, never the value.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose money, lose data, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- Accounts and who owns them. Where the balance lives, and whether it is stored or derived from entries.
- The ledger: entry model, and whether every movement has two sides that sum to zero.
- Money movements: internal transfer, inbound payment, outbound payment, card, refund, reversal, fee.
- The state machine of a payment, including pending, settled, returned and failed.
- External rails and providers, and how their results arrive (synchronous response, webhook, file).
- Customer checks: identity verification, sanctions screening, transaction monitoring.
- Who can read and who can act: customer, staff, third party provider, internal service.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can one request move money twice?** Follow a transfer through a timeout and a retry, all the way to the external rail.
2. **Can a balance go below its limit under concurrency?** Look for a balance read followed by a separate write. It must be one atomic operation or a lock.
3. **Do the books always balance?** Look for a movement recorded as a single update to one account.
4. **Can a caller reach another customer's account?** Read each handler and check that it compares the account's owner, and any consent, with the caller.
5. **What happens when the rail says nothing?** Look for a timeout that marks a payment failed when its real state is unknown, and for a reconciliation job.

## Phase 3: Report

Lead with anything that can lose or duplicate money, unbalance the ledger or expose an account. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start when the user asks for a change, or after they choose a finding. The list below is the target for new endpoints. On an existing endpoint, prefer a compatible migration and report a breaking form as needing a new version and the user's agreement.

- **Create transfer or payment**: requires an idempotency key on new endpoints, scoped to customer plus operation, with a request fingerprint and an atomic claim so concurrent duplicates execute once. It validates limits on the server, writes balanced ledger entries and the payment record in one transaction, and returns a payment state rather than a bare success.
- **Outbound call to a rail**: persists a rail-searchable business reference before the call and sends it with a derived idempotency key or the scheme's unique reference. A timeout returns the same stable payment resource in an unknown state. Retry only if rail lookup conclusively proves absence and the request is still valid; an inconclusive result stays unknown for escalation. It is never retried blindly or marked failed.
- **Balance**: changed by a conditional update or under a lock, in the same transaction as the entries. Available and booked balances are separate fields.
- **Reads**: statements are cursor paginated and stable. A read says how fresh it is.
- **Third party access**: scoped, consented, time limited, revocable, with sender-constrained tokens.
- **Audit**: every state change records who, what, when and on whose authority, in a store the application cannot rewrite.

## What this skill does not do

It does not give regulatory, tax or accounting advice. It tells you where those reviews are needed.
