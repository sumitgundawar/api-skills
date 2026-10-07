# E-commerce API checklist

## Catalogue and price

- [ ] Product and variant identifiers are stable and opaque.
- [ ] Money is an integer in the smallest unit with an ISO 4217 currency code.
- [ ] Price lists carry a currency, a validity period and, where relevant, a market or customer group.
- [ ] Catalogue reads are cacheable with ETags and cursor paginated.
- [ ] Large catalogue exports and imports are asynchronous bulk operations, not thousands of single calls. (Shopify runs bulk mutations from a JSONL file and returns results as JSONL.)
- [ ] Availability shown to shoppers is allowed to be slightly stale. Availability at checkout is checked again.

## Cart

- [ ] The cart is a server-side resource with an identifier, not only client state.
- [ ] Line items reference a variant and a quantity. The server computes prices.
- [ ] Adding the same item twice has a defined result (merge or separate lines).
- [ ] Carts expire and the expiry is visible.
- [ ] Discount codes are validated on the server each time totals are calculated.

## Stock

- [ ] Stock is decremented or reserved in one atomic conditional operation. No read then write.
- [ ] A reservation has an expiry and is released on timeout, cancellation or failed payment.
- [ ] Overselling policy is explicit: never, or allowed up to a limit.
- [ ] Stock changes from several sources (shop, marketplace, warehouse) converge through one authority.
- [ ] Under flash-sale load, reservations go through a queue or a token so demand is admitted at the rate the stock system can handle.

## Checkout and payment

- [ ] Creating a checkout or order requires an idempotency key scoped to `(tenant or principal, operation, key)`, stores a request fingerprint, and atomically ensures that concurrent duplicates execute once.
- [ ] Totals, tax and shipping are fixed on the server at checkout and returned to the client.
- [ ] A `PENDING` payment attempt is stored before the provider call, with its request fingerprint, provider-searchable business reference, stable provider key and later the provider response identifier. The provider key is derived from order plus attempt. The original request and duplicates return the same stable attempt resource while pending or unknown. A timeout is reconciled; retry downstream only after lookup conclusively proves no charge exists and the request is still valid. An inconclusive lookup remains `UNKNOWN` for manual reconciliation. Internal retention covers the retry and reconciliation horizon even when the provider's key window is shorter. (Stripe's v1 API keeps keys for at least 24 hours and replays the first result whether it succeeded or failed.)
- [ ] Disputes and chargebacks are modelled as states driven by provider webhooks, not as manual edits.
- [ ] Rounding is defined once (per line or per order) and applied the same way in every currency.
- [ ] Authorise and capture are separate where the business needs it.
- [ ] The order is confirmed from the provider's webhook or a server-side check, not from the browser returning.
- [ ] Payment failures return a specific, safe error and leave the order retryable.
- [ ] Card data never touches your servers. Hosted fields or tokens reduce your PCI DSS scope. They do not remove it.
- [ ] Strong customer authentication steps (3-D Secure) are handled as a state, not an error.

## Orders

- [ ] The order state machine is written down. Each transition is an explicit operation with a rule about who may call it.
- [ ] Updates use a version and `If-Match`. Two staff members editing one order cannot overwrite each other silently.
- [ ] Every order endpoint checks that the caller owns the order (OWASP API1).
- [ ] Order numbers shown to customers are not guessable sequences used as the only access check.
- [ ] Cancellation and refund are idempotent, and a partial refund cannot exceed what was captured.
- [ ] Orders are never hard deleted. Personal data can be erased or anonymised while financial records are retained as the law requires.

## Webhooks and integrations

- [ ] Incoming webhooks: signature and replay timestamp verified on the raw body; raw event durably inserted into an inbox before 2xx; business effect and `PROCESSED` marker committed atomically; duplicates acknowledged; retries bounded; exhausted events alerted, owned and replayable.
- [ ] Out-of-order events are handled by fetching current state or comparing versions.
- [ ] A reconciliation job compares your records with the provider's, daily at least.
- [ ] Outgoing webhooks: signed, retried with backoff, replayable.
- [ ] Calls to marketplaces and carriers have timeouts, a retry budget and a circuit breaker.
- [ ] Third-party responses are validated before use (OWASP API10, unsafe consumption of APIs).

## Load

- [ ] Checkout capacity is reserved. Recommendations, search suggestions and analytics are shed first.
- [ ] The authenticated checkout path is load tested. Shopify found bottlenecks there that anonymous browsing tests had hidden.
- [ ] Limits distinguish real shoppers from automation. Shopify's Storefront API does not rate limit real buyer traffic, limits bots, and limits unsigned bots most strictly.
- [ ] High-demand drops use a waiting room or queue and per-customer purchase limits.

## Abuse

- [ ] Sensitive business flows are protected from automation: account creation, login, gift card balance checks, coupon validation, checkout of limited stock (OWASP API6).
- [ ] Price and stock scraping is expected. Catalogue endpoints have cost-based limits, and bulk access is offered on separate terms.
- [ ] Account takeover defences exist on login and on changes to email, password and address.

## Agents

- [ ] A machine-readable shop profile is published. The Universal Commerce Protocol uses `/.well-known/ucp` to advertise capabilities.
- [ ] Checkout is a server-side state machine an agent can drive. UCP's checkout states include `incomplete`, `requires_escalation` (hand off to the buyer through a continuation URL) and `ready_for_complete`.
- [ ] Product data is complete and structured: identifiers, variants, price, availability, shipping, returns.
- [ ] Payment by an agent uses a scoped, expiring token (for example Stripe Shared Payment Tokens, or network agent tokens), never the buyer's card number.
- [ ] The agent's identity is verified by signature where possible (Web Bot Auth underlies Visa's Trusted Agent Protocol and Mastercard Agent Pay).
- [ ] There is an explicit rule for what an agent may do without the buyer confirming, and a spending limit.
- [ ] Agent-originated orders are labelled in your data.

Status note: UCP (Google and Shopify, January 2026), the Agentic Commerce Protocol (OpenAI and Stripe, September 2025) and AP2 are young and changing. Check the current specification before building.

## Also check

- [ ] Card testing is expected. Attackers use a payment endpoint to try stolen card numbers in bulk. Payment attempts are limited per card, per account, per device and per address, and a run of declines raises an alert.
- [ ] Tax is calculated by one owner (a tax service or the payment provider), from the buyer's verified location, and the rate and its source are stored on the order.
- [ ] A refund goes back to the original payment method, and the API cannot redirect it elsewhere.
- [ ] If sellers other than you are paid through the platform, the `api-marketplace` skill applies to payouts, seller checks and disputes.

## Sources

- Stripe API reference: Idempotent requests; Payment Intents; Webhooks; Shared Payment Tokens; Machine payments.
- Shopify developer docs: API limits; Bulk operations; Storefront API rate limits. Shopify Engineering: How we prepare Shopify for BFCM (2025); Building the Universal Commerce Protocol (2026).
- OWASP API Security Top 10 (2023).
- PCI DSS version 4.0.1.
- Cloudflare, Securing agentic commerce (Visa and Mastercard on Web Bot Auth).
