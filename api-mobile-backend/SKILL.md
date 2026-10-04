---
name: api-mobile-backend
description: Reviews, designs and changes APIs that serve mobile and other installed apps. Covers old app versions that cannot be recalled, backends for frontends, flaky networks and retries, offline use and sync conflicts, payload size, push tokens, app attestation, forced upgrades, feature flags and in-app purchases. Use when the main client is an iOS, Android, desktop or TV app, when the user mentions mobile, app version, offline, sync, BFF, push token, deep link, App Attest, Play Integrity, force update or in-app purchase, or when asked to make an API safe to change while old apps are still installed.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Mobile backend APIs

An installed app is a client you shipped once and cannot take back. Some people will run this year's build for five years, on a train, in a tunnel. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the rules below.

## Ground rules

1. Treat every released app version as a live consumer of the contract. Never remove or change something an installed version depends on without the user's explicit go-ahead and usage data.
2. Nothing in an app is secret. Keys, endpoints and checks in the client can be read and changed by its owner.
3. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance, and only after the user agrees.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can break installed apps, lose data, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- Platforms and the versions still in use, with their share of traffic.
- How a request identifies the app, its version and its platform.
- The API shape: general API, backend for frontend, GraphQL, and who owns it.
- What works offline, and how changes made offline are sent later.
- Push: where device tokens are stored and when they are removed.
- Authentication on the device: tokens, refresh, biometric unlock, attestation.
- Purchases made through the app stores.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Would this change crash a version that is still installed?** Look for removed fields, new enum values and changed nullability, against the oldest supported build.
2. **Does a retry on a bad connection repeat the action?** Look for writes without an idempotency key.
3. **Do two devices overwrite each other?** Look at how offline edits are merged.
4. **Does the server trust the app?** Look for prices, roles, purchase results or validation done only in the client.
5. **Can the team stop an old version?** Look for a minimum version check that the oldest build actually obeys.

## Phase 3: Report

Lead with anything that breaks installed apps or trusts the client. Give the evidence, the affected versions and their share, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. Every change is additive unless usage data shows no installed version depends on the old form.

- **Version signal**: every request carries app, version, platform and build. The server logs them and can answer by version.
- **Writes**: an idempotency key generated on the device and kept across retries and app restarts.
- **Sync**: changes sent as operations with a base version; the server detects conflicts and returns them; deletes are tombstones.
- **Payloads**: only what the screen needs, compressed, cursor paginated, with ETags so an unchanged response costs almost nothing.
- **Kill switches**: a minimum supported version, a soft prompt, and remote flags, all shipped before they are needed.
- **Purchases**: receipts verified on the server with the store, and store notifications treated as the source of truth.

## What this skill does not do

It does not review the app's own code or the app stores' policies. It reviews the contract between the app and the server.
