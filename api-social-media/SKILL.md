---
name: api-social-media
description: Reviews, designs and changes APIs for social and community platforms. Covers identity and the social graph, posts and media, feeds and fan-out, reactions and counters, direct messages, notifications, moderation and reporting, age assurance, researcher and regulator data access, scraping and bot pressure, and federation (ActivityPub, AT Protocol). Use when the project has user-generated content, followers, feeds, comments, messaging or moderation, or when the user mentions timeline, feed, followers, likes, reports, trust and safety, DSA or scraping of user content.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Social media APIs

A social platform's API serves reads at enormous fan-out, holds content that people regret and want removed, and is the main target of scrapers and automation. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. Never widen who can see a piece of content as a side effect of another change. Visibility rules are the product's promise to its users.
2. Deletion and blocking must take effect everywhere the content or the relationship is cached, indexed or copied. Trace it.
3. Do not add data to a public or partner endpoint without checking it against privacy settings, age and consent.
4. Moderation and safety operations are privileged. Keep them on separate routes with separate checks and a full audit trail.
5. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance with seeded test accounts, and only after the user agrees.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can expose private content, defeat a block, fail to delete, or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

Map the domain:

- Accounts, profiles, privacy settings, age status.
- The graph: follow, friend, block, mute, and their direction.
- Content: posts, replies, media, edits, deletions, visibility.
- Feeds: how a timeline is built, and whether fan-out happens on write, on read, or both.
- Engagement: reactions, counters, bookmarks.
- Messaging: direct and group, and whether it is end-to-end encrypted.
- Notifications and real-time delivery.
- Moderation: reports, decisions, appeals, automated classifiers.
- External access: public API, partner API, researcher access, embeds, federation.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Does every read path enforce visibility and blocks?** Check the post endpoint, the feed, search, notifications, embeds, the export and every cache. One path that forgets is a privacy incident.
2. **Is a delete really a delete?** Follow a deleted post through feeds, search, caches, media storage, federation and partner copies.
3. **Can the API be used to harvest users?** Look for endpoints that reveal whether an email or phone number has an account, unbounded follower lists, and identifiers that can be enumerated.
4. **What does a celebrity account do to the feed?** Find the fan-out path and its limits.
5. **Can automation fake engagement or flood reports?** Look at limits on follow, like, post, message and report, per account and per device.

## Phase 3: Report

Lead with anything that exposes private content, defeats a block, or fails to delete. Then abuse at scale. Then performance. Then the checklist table and what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form (accept the key, add a cursor parameter beside the offset) and report the required form as a breaking change that needs a new version and the user's agreement.

Default design for the endpoints that matter:

- **Create post, reply, message**: accepts an idempotency key, and requires it on new endpoints or in a new version, so a retry on a poor mobile connection does not double post.
- **Feeds**: cursor paginated on new endpoints, with a cursor added beside any existing offset; the cursor encodes position, not a page number; the response says how fresh it is.
- **Counters**: approximate and eventually consistent for display; exact only where money or policy depends on them; changed with relative operations.
- **Follow, like, react**: idempotent by construction. PUT to set, DELETE to unset, so repeating either is harmless.
- **Delete and block**: return at once, then propagate through a pipeline with a tombstone event; verified by a test that checks every read path.
- **Lists of users**: bounded, paginated, permission-checked, and rate limited by cost.
- **Report content**: idempotent per reporter and item; rate limited; routed to a queue with a priority.
- **Public and partner APIs**: separate from the product API, with their own identity, limits, terms and price.

## What this skill does not do

It does not give legal advice on the EU Digital Services Act, the UK Online Safety Act, age restriction laws or data protection. It tells you where those reviews are needed.
