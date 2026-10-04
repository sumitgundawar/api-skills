# Fintech and banking API checklist

## Money and the ledger

- [ ] Amounts are integers in the smallest unit, or decimals, with an ISO 4217 currency code. No floats anywhere on the path, including JSON parsing in clients you ship. The number of minor units comes from ISO 4217 per currency (none for the yen, three for the Kuwaiti dinar), never from an assumed factor of 100.
- [ ] Every movement is recorded as balanced entries (double entry). The sum of all entries for a transaction is zero.
- [ ] Entries are append only. Corrections are new entries that reference the original.
- [ ] A stored balance is updated in the same transaction as its entries, and a job proves that stored balances equal the sum of entries.
- [ ] Currency conversion records the rate, its source and its time. Rounding is defined once.
- [ ] Available balance and booked balance are distinct, and holds have an expiry.

## Transfers and payments

- [ ] Creating a payment accepts an idempotency key, scoped to the customer. The same key with a different body is rejected.
- [ ] A payment is a resource with a state machine. The API never answers only "ok".
- [ ] Limits (per transaction, per day, per counterparty) are enforced on the server inside the transaction.
- [ ] Concurrent debits cannot overdraw: a conditional update, a row lock or a serialisable transaction.
- [ ] The external reference sent to a rail is unique and stored before the call is made.
- [ ] A timeout or an ambiguous response leaves the payment pending or unknown. Only a definitive answer from the rail moves it to failed.
- [ ] Returns, reversals and chargebacks are modelled as their own movements that link to the original.
- [ ] Scheduled and recurring payments are safe to run twice.

## Reconciliation

- [ ] A job compares your records with each provider's reports at least daily and raises every difference.
- [ ] Incoming webhooks and files are deduplicated on the provider's identifier and tolerate arriving late or out of order.
- [ ] There is an operational view of payments stuck in a non-final state, with an age.

## Access and consent

- [ ] Every account endpoint checks ownership or a valid mandate. Identifiers such as account numbers are never the only check.
- [ ] Sensitive actions (new payee, large transfer, change of contact details) require step-up authentication. In the UK and EU this is strong customer authentication.
- [ ] Third party access follows the regulator's or scheme's profile where one applies. Open banking profiles build on the FAPI security profiles. FAPI 1.0 Advanced (used by UK Open Banking) requires certificate-bound tokens and signed request objects. FAPI 2.0 allows mutual TLS or DPoP, and puts message signing in a separate profile. Explicit, time-limited consent comes from the open banking standard itself. Follow the profile your scheme mandates.
- [ ] Consent is a resource the customer can list and revoke, and revocation takes effect at once.
- [ ] Staff access is by role, is logged, and has a second approver for high-value actions.

## Fraud and abuse

- [ ] Account opening, login, payee creation and payment are protected from automation and credential stuffing.
- [ ] Payee name checking is used where the scheme offers it (Confirmation of Payee in the UK, Verification of Payee in the EU).
- [ ] Error messages do not reveal whether an account, a customer or a card exists.
- [ ] Velocity rules and transaction monitoring can hold a payment for review without losing it.
- [ ] Sanctions screening happens before funds leave, and its result is stored.

## Data and audit

- [ ] An audit record exists for every state change: actor, authority, time, before and after. The application cannot alter it.
- [ ] Personal and financial data is encrypted at rest and in transit. Full account and card numbers are masked in responses and absent from logs.
- [ ] Retention follows the law that applies to you. Financial records usually have to be kept for years even after an account closes, so erasure requests are handled by restricting, not deleting, those records. Take advice.
- [ ] Card data stays with a provider wherever possible. If you hold it, PCI DSS applies in full.

## Messages and formats

- [ ] Where you exchange bank messages, the format is the one the scheme uses. Many schemes have moved or are moving to ISO 20022.
- [ ] Account identifiers are validated (IBAN check digits, sort code and account number rules) before a payment is accepted.
- [ ] Dates distinguish the instant a thing happened from the business or value date.

## Load and resilience

- [ ] Payment creation has reserved capacity. Statements, exports and analytics are shed first.
- [ ] Calls to each rail have a timeout, a retry budget and a circuit breaker, and a slow rail cannot exhaust your workers.
- [ ] Month end, salary day and tax deadlines are load tested as the peaks they are.

## Also check

- [ ] Strong customer authentication for a payment is dynamically linked: the authentication code is bound to the amount and the payee, and changing either invalidates it (PSD2 regulatory technical standards, Article 5).
- [ ] Idempotency keys and unique references are kept longer than the rail's own retry and return window, which can be days. Twenty-four hours is not enough for most rails.
- [ ] Payee name checking reveals whether a name matches, by design. It is the one deliberate exception to not revealing whether an account exists, and it is rate limited for that reason.
- [ ] When `api-marketplace` is also installed, this skill's ledger and payment rules take precedence for anything that moves money.

## Sources

- OpenID Foundation: FAPI 1.0 Advanced; FAPI 2.0 Security Profile and Message Signing.
- RFC 8705 (mutual TLS client authentication and certificate-bound tokens); RFC 9449 (DPoP).
- UK Open Banking Standard; EU PSD2 regulatory technical standards on strong customer authentication.
- ISO 20022; ISO 4217; ISO 13616 (IBAN).
- PCI DSS version 4.0.1.
- OWASP API Security Top 10 (2023).
- Stripe API reference, Idempotent requests.
