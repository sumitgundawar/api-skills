# Subscription and billing API checklist

## Catalogue

- [ ] Money is an integer in the smallest unit with a currency code. Tiny unit prices (per token, per request) use a decimal type with enough precision, and rounding happens once, at the invoice line.
- [ ] A price is immutable once a subscription uses it. Changes create a new price.
- [ ] Each subscription records the price it is on, so a catalogue change does not move existing customers silently.
- [ ] Plans, add-ons, seats and usage components are separate line items.
- [ ] Coupons and credits have a scope, a limit, an expiry and an audit trail.

## Subscription lifecycle

- [ ] The state machine is written down, and each transition is an explicit operation.
- [ ] Create, upgrade, downgrade, pause and cancel accept an idempotency key.
- [ ] Changes carry an effective time: now, at period end, or a date. Scheduled changes are visible and cancellable.
- [ ] A preview endpoint returns the exact invoice lines a change would produce.
- [ ] Proration follows one written rule, with tests for month ends, leap years, daylight saving changes and two changes in one period.
- [ ] The billing anchor and the time zone used for period boundaries are stored per subscription.
- [ ] Trials end by a job that is safe to run twice, and the customer is told beforehand.
- [ ] Cancellation is as easy as sign-up, and says what the customer keeps until the period ends. Several jurisdictions now require this.

## Usage metering

- [ ] Every usage event has a unique identifier, and ingestion is idempotent on it.
- [ ] Events carry the time they happened, separate from the time they were received.
- [ ] The sender persists an event before sending it, and retries until it is acknowledged.
- [ ] Late events have a rule: accepted until the period's invoice is finalised, then billed in the next period or dropped, as documented.
- [ ] Aggregation (sum, maximum, unique count, last value) is defined per meter and is reproducible from raw events.
- [ ] Raw events are kept long enough to answer a dispute.
- [ ] Ingestion has its own capacity and can absorb bursts through a queue.
- [ ] Customers can read their current usage and a projected charge through the API, with a stated delay.
- [ ] Spending limits and alerts exist, especially where usage is driven by automated callers.

## Invoices

- [ ] An invoice is a draft until finalised, then immutable. Corrections are credit notes.
- [ ] The invoicing job is idempotent per subscription and period. A unique constraint backs that up.
- [ ] Totals can be recomputed from stored lines, and the stored tax rate and its source are on each line.
- [ ] Invoice numbers follow the rules of the seller's jurisdiction.
- [ ] Tax is calculated from the customer's verified location and status, by a service or a provider, not by a constant.
- [ ] Refunds and credits cannot exceed what was paid.

## Payment collection

- [ ] Charging an invoice carries an idempotency key derived from the invoice and the attempt.
- [ ] Failed payments follow a retry schedule with customer messages. The subscription moves to past due, and access follows a stated grace rule.
- [ ] Authentication steps required by the bank (3-D Secure) are states, not errors.
- [ ] Payment method updates take effect on the open invoice.
- [ ] Renewals charged while the customer is absent rest on a stored mandate or consent, captured when the payment method was saved.
- [ ] A provider timeout while charging leaves the invoice in a "payment unknown" state that a status check or webhook resolves. It is neither marked paid nor charged again.
- [ ] A customer's billing currency is fixed. Changing it is an explicit migration, not a field update.
- [ ] Billing provider keys and webhook secrets never appear in code, logs or the agent's own output.
- [ ] Provider webhooks are verified, deduplicated and tolerant of order. A daily job reconciles subscriptions, invoices and payments with the provider.

## Entitlements

- [ ] The product asks one service what a customer may use. Clients never decide.
- [ ] Entitlement changes are pushed as events, and caches have a short lifetime.
- [ ] Quota exhaustion returns a specific error that names the limit and how to raise it.
- [ ] If billing is down, the rule is explicit: keep the last known entitlements for a stated time.

## Access and audit

- [ ] Billing endpoints check that the caller belongs to the account and has a billing role.
- [ ] Every change to price, quantity, discount or invoice records who made it. Manual adjustments need a reason.
- [ ] Customer-facing invoice and receipt links are unguessable and expire.

## Testing

- [ ] Time can be moved in tests (a test clock), so renewals, trials and retries are tested without waiting.
- [ ] A suite of worked examples with expected amounts runs in CI.

## Sources

- Stripe Billing documentation: subscriptions, prorations, usage-based billing and meters, test clocks, webhooks.
- Stripe API reference, Idempotent requests.
- OWASP API Security Top 10 (2023).
