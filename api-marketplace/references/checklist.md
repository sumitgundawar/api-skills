# Marketplace API checklist

## Seller onboarding

- [ ] Verification state is a state machine (for example pending, verified, restricted, rejected), and every money path checks it.
- [ ] Identity and business checks are done by a regulated provider where possible, and you store the result and a reference, not the documents.
- [ ] Bank details are changed only after step-up authentication, and a change delays the next payout and notifies the seller.
- [ ] Requirements can change. The API can tell a seller what is now missing and by when.
- [ ] Onboarding is protected from automation and from the same person returning under a new account.

## Listings

- [ ] Each listing has an owner and every write checks it.
- [ ] Price, currency, tax treatment and availability are validated on the server.
- [ ] Changes to a listing do not change orders already placed. The order stores a snapshot of what was bought.
- [ ] Bulk create and update are asynchronous operations with per-item results.
- [ ] Content goes through moderation before or soon after it is visible, and prohibited items have a fast path.

## Search and ranking

- [ ] Search is cursor paginated, with cost-based limits and a cap on how deep a caller can page.
- [ ] Ranking inputs that sellers can influence are protected from manipulation.
- [ ] Paid placement is labelled in the response, so every client can show it.
- [ ] Results respect blocks, regional rules and availability at read time.

## Orders and bookings

- [ ] The state machine is written down, with the party allowed to make each transition.
- [ ] Creating an order accepts an idempotency key. Limited availability is reserved atomically, with an expiry.
- [ ] Cancellation rules (who, until when, at what cost) are computed on the server and returned before the caller commits.
- [ ] Both parties see the same state, and each state change emits an event to both.

## Money

- [ ] It is clear, in code and in terms, who the merchant of record is and who holds funds. Holding client money is a regulated activity in many places. Take advice.
- [ ] Every movement (charge, fee, tax, hold, release, payout, refund, reversal, adjustment) is a balanced ledger entry.
- [ ] The seller's balance is derived from the ledger. Available and pending amounts are separate.
- [ ] Payouts carry an idempotency key to the provider, run on a schedule that is safe to run twice, and reconcile daily against the provider's reports.
- [ ] A refund or chargeback after payout follows a written rule, and negative seller balances are recovered or written off explicitly.
- [ ] Fees and commissions are versioned. An order keeps the fee schedule it was placed under.
- [ ] Multi-currency orders record the rate, its source and who bears the difference.
- [ ] Tax collection and reporting duties are identified. Platforms have reporting duties about their sellers in the EU (DAC7), the UK and the US.

## Disputes and refunds

- [ ] A dispute is a resource with states, evidence, deadlines and an outcome, driven by provider webhooks.
- [ ] Opening a dispute places a hold on the related funds.
- [ ] Partial refunds cannot exceed what was captured, and are idempotent.

## Reviews and messaging

- [ ] A review requires a completed transaction between the two parties.
- [ ] Reviews can be reported, moderated and removed, with a record of why.
- [ ] Messages between parties are rate limited, scanned for attempts to move payment off the platform where your terms forbid it, and reportable.
- [ ] Contact details are released only when the transaction needs them, and are withheld in list and search responses.

## Trust and safety

- [ ] Account takeover defences cover login and changes to email, password, bank details and payout schedule.
- [ ] Listing, profile and review endpoints have limits sized for a person, and bulk access is on separate terms.
- [ ] Collusion patterns (self-purchase, review rings, refund abuse) have signals and a review queue.
- [ ] Blocking a user takes effect across search, messaging and booking.
- [ ] Illegal content and safety reports have a distinct, fast path with a named owner. Online marketplaces in the EU have trader traceability duties under the Digital Services Act.

## Seller API

- [ ] Sellers who integrate get scoped keys, webhooks, a sandbox with test buyers, and a published version policy.
- [ ] Order and inventory webhooks are signed, retried and replayable.
- [ ] Stock or calendar sync from several channels converges through one authority.

## Sources

- Stripe Connect documentation: account types, separate charges and transfers, payouts, disputes.
- Adyen for Platforms documentation.
- EU Council Directive 2021/514 (DAC7); EU Digital Services Act, Article 30 (traceability of traders).
- OWASP API Security Top 10 (2023).
