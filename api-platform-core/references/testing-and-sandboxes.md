# 14. Testing and sandboxes

Consumers need somewhere to practise, and you need proof that a change did what you intended and nothing else.

## Checklist: tests

- [ ] Contract tests run in CI: the implementation matches the contract, and the contract did not break compared with the last release.
- [ ] Consumer-driven contract tests exist for the most important consumers.
- [ ] The failure cases are tested, not only the happy path: a repeated request, two concurrent writers, a page boundary, a missing permission, a request over the limit, a timeout from a dependency.
- [ ] Authorisation tests try to reach another tenant's objects and expect to fail.
- [ ] Load tests run regularly against production-like data, to the point of failure, so that you know where the ceiling is.
- [ ] Failure injection is practised: a dependency that is slow, a dependency that is down, a network partition.
- [ ] For risky migrations, sanitised traffic may be replayed against old and new paths in isolated destinations and the responses compared. Production credentials and external side effects are disabled; writes are shadowed or redirected. Idempotency alone does not make production replay safe.
- [ ] Deployments are gradual, with automatic rollback on error budget burn.

## Checklist: sandbox

- [ ] A sandbox exists and is free to use.
- [ ] It exercises the same contract, business rules and state transitions as production. Provider simulators and mocks are useful for contract and failure tests, but their differences from production are documented and checked for drift.
- [ ] It is isolated from production data and from other consumers' test data.
- [ ] Credentials are distinct and visibly different from production ones.
- [ ] There are documented test values that always produce the same outcome: a card that is declined, a number that is unreachable, an account with no funds.
- [ ] Time can be controlled, so that renewals, expiries and retries can be tested without waiting.
- [ ] Failures can be triggered deterministically on demand: timeouts, 5xx responses, and webhooks that arrive late, twice or out of order.
- [ ] Webhooks and events use the production envelope and receiver path. A specific past event can be replayed with the same identifier, and a test proves that replay does not duplicate the business effect.
- [ ] The webhook crash matrix covers: after inbox insert before 2xx; after 2xx before claim; after claim before effect; concurrent duplicates; same identifier with a different payload; and, for outbox effects, after local commit before the downstream response.
- [ ] A contract-drift test compares the sandbox or simulator with the production contract and documented state transitions.
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
