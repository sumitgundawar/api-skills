# 10. Versions and retirement

You will need to change something that people depend on. Decide how before you need to.

## Checklist

- [ ] There is a written, public versioning policy: how versions are named, how long each is supported, and how much notice a removal gets.
- [ ] Changes that are additive in the schema normally ship in the current version only after tolerant-reader rules, representative client tests and behavioural compatibility show they are safe. "Additive" is not proof.
- [ ] Breaking changes ship only in a new version, on a predictable schedule.
- [ ] Each consumer is pinned to a version and stays on it until they choose to move.
- [ ] You can answer "who still uses version X, and how much" per consumer. If you cannot, fix that first.
- [ ] Deprecated operations and fields are marked in the contract and in responses.
- [ ] There is a changelog, with upgrade notes for every breaking change.
- [ ] Preview or beta features are clearly labelled and can change without the full notice period.

## Naming versions

- A dated version (`2026-09-30`) is the most common choice at large platforms: Stripe (`Stripe-Version` header), GitHub (`X-GitHub-Api-Version` header), Shopify (in the path).
- A major number in the path (`/v1`, `/v2`) suits a complete redesign, not routine evolution.
- GraphQL usually evolves one schema continuously and marks fields `@deprecated`.

## A published Stripe architecture

Stripe described this architecture in 2017; treat it as a useful historical pattern, not a claim about every current endpoint. The core logic produces the newest version. Each breaking change is a small module that converts the new response shape back to the previous one. A response for an older version applies those modules in reverse order. Most of the cost of an old version sits in those modules. It is not free: changes with side effects leak into the core, each feature is tested against every pinned version, and typed SDKs are tied to one version. Since 2024, Stripe's published release process has confined breaking changes to named major releases while more frequent releases contain compatible changes.

## Published support windows (read October 2026)

| Platform | Commitment |
|----------|------------|
| Shopify | A new version each quarter. Each stable version supported for at least 12 months. A retired version falls forward to the oldest supported one. |
| GitHub REST | The previous version is supported for at least 24 months after a new one is released. Retired versions answer 410. |
| Meta Graph API | A version stops working two years after the next one is released. |
| Microsoft Graph | At least 24 months of notice before a generally available API or version is removed. |
| Salesforce | Each version supported for at least three years, with at least one year of notice before retirement. |

These measure different things (support from release, support after a successor, notice before removal). Compare them with care.

Shopify's fall-forward is a trade-off, not a free win. Callers keep working, but they silently receive a different contract from the one they asked for. A 410 is the opposite choice: loud, and unambiguous.

Pick a number, publish it, and keep it.

## Retirement runbook

1. **Measure.** Usage per consumer and per version. Find the owners.
2. **Announce.** Changelog, email to owners, dashboard warnings. State the date.
3. **Signal in the protocol.** Send `Deprecation` (RFC 9745) on every response from the deprecated operation, and `Sunset` (RFC 8594) with the removal date. Add a `Link` header pointing at the migration guide.

   ```
   Deprecation: @1767225600
   Sunset: Wed, 30 Jun 2027 23:59:59 GMT
   Link: <https://api.example.com/docs/migrate-orders-v2>; rel="deprecation"
   ```

4. **Exercise compatibility.** When disruption is justified, use an announced, reversible test on a small controlled slice of old-version traffic while owners are watching. Define success and stop criteria, provide a kill switch, monitor impact and roll back immediately when the threshold is crossed. If the exercise returns a temporary error, send `Cache-Control: no-store` and state when normal service resumes. A blanket outage is not the default.
5. **Remove.** Answer 410 Gone with a problem-details body that links to the guide. Keep the 410 for a long time.
6. **Review.** Record who broke and why, and improve step 1 for next time.

## Sources

- Stripe, APIs as infrastructure: future-proofing Stripe with versioning (2017); Introducing Stripe's new API release process (2024); API versioning docs.
- GitHub docs, API versions. Shopify docs, API versioning. Salesforce API end-of-life policy. Microsoft Graph versioning and support. Meta Graph API changelog.
- RFC 9745, The Deprecation HTTP Response Header Field (2025). RFC 8594, The Sunset HTTP Header Field.
- Google AIP-185 (versioning), AIP-181 (stability levels).
