# 14. Testing and sandboxes

Consumers need somewhere to practise, and you need proof that a change did what you intended and nothing else.

## Checklist: tests

- [ ] Contract tests run in CI: the implementation matches the contract, and the contract did not break compared with the last release.
- [ ] Consumer-driven contract tests exist for the most important consumers.
- [ ] The failure cases are tested, not only the happy path: a repeated request, two concurrent writers, a page boundary, a missing permission, a request over the limit, a timeout from a dependency.
- [ ] Authorisation tests try to reach another tenant's objects and expect to fail.
- [ ] Load tests run regularly against production-like data, to the point of failure, so that you know where the ceiling is.
- [ ] Failure injection is practised: a dependency that is slow, a dependency that is down, a network partition.
- [ ] For risky migrations, real traffic is replayed against the old and new paths and the responses are compared. Only safe for idempotent requests.
- [ ] Deployments are gradual, with automatic rollback on error budget burn.

## Checklist: sandbox

- [ ] A sandbox exists and is free to use.
- [ ] It runs the same code path as production. A separate mock proves nothing.
- [ ] It is isolated from production data and from other consumers' test data.
- [ ] Credentials are distinct and visibly different from production ones.
- [ ] There are documented test values that always produce the same outcome: a card that is declined, a number that is unreachable, an account with no funds.
- [ ] Time can be controlled, so that renewals, expiries and retries can be tested without waiting.
- [ ] Failures can be triggered on demand: timeouts, 5xx responses, webhooks that arrive late or twice.
- [ ] Webhooks and events work in the sandbox exactly as in production.
- [ ] Sandbox traffic is the first to be shed under load.
- [ ] A sandbox can be created by a program without a person filling in a form. Coding agents need this.
- [ ] Test data can be reset.

## Three models that work at scale

1. **A separate copy per team.** Stripe Sandboxes: up to five isolated environments per account in addition to the original test mode, each with its own keys and settings, and simulated time for billing tests.
2. **A tenant inside a shared environment.** Uber (SLATE) and DoorDash tag a test request with a tenancy value that is propagated across services in production, and each service routes tagged requests to the version under test. Lyft does the same inside a shared staging environment (staging overrides). Real dependencies, no duplicate environment, strict isolation of test data.
3. **One per agent.** Stripe lets a coding agent provision an anonymous sandbox with working keys from the command line, with no account registration.

## Migrating storage under a live API

Stripe's published pattern, four steps, one at a time:

1. Write to both the old and the new store. Two writes are not atomic and will drift, so run a reconciliation alongside.
2. Move reads to the new store, while comparing results from both in production.
3. Move writes so the new store is the source of truth.
4. Remove the old code and data.

Netflix moved its mobile apps to a new API layer with zero downtime using three tools in sequence: AB tests, replay of production traffic against both paths, and sticky canaries.

## Sources

- Stripe docs: Sandboxes; Testing use cases. Stripe, Online migrations at scale (2017).
- Uber Engineering, Simplifying developer testing through SLATE. Lyft Engineering, Scaling productivity on microservices at Lyft, part 3.
- Netflix Tech Blog, Migrating Netflix to GraphQL safely (2023).
- Shopify Engineering, How we prepare Shopify for BFCM (2025).
