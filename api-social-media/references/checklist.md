# Social media API checklist

## Identity and graph

- [ ] Account identifiers are opaque and not enumerable. Handles can change. Identifiers do not.
- [ ] Endpoints do not reveal whether an email or phone number is registered, except to the owner.
- [ ] Contact upload ("find friends") is the usual harvest path. It is rate limited per account and per device, capped in size, matches only people who have opted in to being found, and never returns a match for a number the uploader could not plausibly know.
- [ ] Follow, block and mute are idempotent: PUT to set, DELETE to unset.
- [ ] A block is enforced in both directions on every read path: profile, posts, feed, search, mentions, messages, notifications, embeds.
- [ ] Follower and following lists respect the account's privacy setting, are paginated with cursors, and have a cost-based limit.
- [ ] Graph changes emit events so feeds and caches can react.

## Content

- [ ] Creating a post, reply or message requires an idempotency key.
- [ ] Visibility (public, followers, named people) is stored on the content and checked on every read, including by identifier.
- [ ] Edits keep a history where policy requires it, and bump a version.
- [ ] Media uploads go directly to storage with a pre-signed URL, are scanned before they are served, and can resume.
- [ ] Deleting returns at once and starts a pipeline: remove from feeds, search, caches and media storage; emit a tombstone; notify federated or partner copies.
- [ ] A test proves that a deleted or newly private item is not returned by any endpoint.
- [ ] Content has provenance metadata where the platform supports it (for example C2PA for media).

## Feeds

- [ ] Cursor pagination only. Offsets repeat and skip items as new content arrives.
- [ ] The feed strategy is deliberate: fan-out on write for ordinary accounts, fan-out on read (or a hybrid) for accounts with very many followers.
- [ ] Visibility and blocks are re-checked when the feed is read, not only when it was built.
- [ ] The response is cacheable per user for a short time, and says how fresh it is.
- [ ] Ranking inputs that are personal data are documented, and users can choose a non-profiled feed where the law requires one.

## Engagement and counters

- [ ] Likes and reactions are idempotent by construction.
- [ ] Display counters are approximate and eventually consistent. Do not run an exact count per page view.
- [ ] Counters are updated with relative operations and reconciled periodically.
- [ ] Engagement endpoints have per-account and per-device limits tuned to human behaviour.

## Messaging and real time

- [ ] Sending a message is idempotent with a client-generated identifier, and the same identifier orders and deduplicates on the receiving side.
- [ ] Delivery is at least once. Clients deduplicate.
- [ ] Real-time connections (WebSocket, server-sent events) have authentication, per-connection limits, heartbeats and a documented resume mechanism.
- [ ] If messages are end-to-end encrypted, the API never requires plaintext on the server, and reporting flows are designed around that.

## Moderation and safety

- [ ] Reporting is idempotent per reporter and item, rate limited, and available without leaving the content.
- [ ] Moderation actions are on privileged routes, fully audited, and reversible where policy allows.
- [ ] Decisions carry a reason that can be shown to the user, and there is an appeal operation.
- [ ] Automated classifiers are a signal into a queue with priorities, with human review for high-impact actions.
- [ ] Abuse of the report endpoint itself (mass reporting) is detected.
- [ ] Illegal content has a distinct, fast path with evidence preservation.

## Age and consent

- [ ] The platform records an age status for each account and the method used to establish it.
- [ ] Features, defaults and data exposure differ by age status, and the API enforces the difference on the server.
- [ ] Age assurance is a separate service or provider behind a narrow interface, so methods can change by market without touching product endpoints.
- [ ] Rules by market are configuration, not code. Examples to plan for: Australia's minimum age of 16 for social media accounts (enforced from 10 December 2025); the UK Online Safety Act's requirement for highly effective age assurance for certain content.

## External access

- [ ] The public or partner API is separate from the product API, with its own credentials, limits, terms and pricing.
- [ ] Every field exposed externally is checked against privacy settings and age status.
- [ ] Bulk access is by contract only, metered and audited.
- [ ] Researcher access is planned for. The EU Digital Services Act (Article 40) and its delegated regulation oblige very large platforms to give vetted researchers access to data through defined interfaces and to publish a data inventory.
- [ ] Embeds and link previews do not leak private content or allow tracking beyond what is declared.

## Scraping and automation

- [ ] Assume public content will be scraped. Decide what is public on purpose.
- [ ] Limits rise with the strength of identification: anonymous lowest, declared bots higher, signed or contracted access highest.
- [ ] Unauthenticated endpoints return little and are heavily cached.
- [ ] Automation that imitates people (fake engagement, mass account creation) is treated as abuse of a sensitive business flow (OWASP API6): device attestation on mobile, risk scoring, step-up challenges.
- [ ] Suspicious accounts can be asked to prove a person is behind them without revealing who that person is. Reddit announced this approach in March 2026.
- [ ] Limits are cost-based. Bluesky, for example, charges 3 points to create a record, 2 to update and 1 to delete, with 5,000 points an hour and 35,000 a day per account.

## Federation

- [ ] If the platform federates (ActivityPub, AT Protocol), deletes and blocks are sent to peers, and you document that you cannot guarantee a remote server honours them.
- [ ] Incoming federated content goes through the same moderation and limits as local content.
- [ ] Signatures on federated requests are verified, and fetches of remote URLs are protected against server-side request forgery (OWASP API7).

## Sources

- OWASP API Security Top 10 (2023).
- Bluesky documentation, Rate limits. AT Protocol specification. W3C ActivityPub.
- Slack developer changelog, rate limit changes for non-Marketplace apps (29 May 2025).
- TechCrunch, Reddit human verification (25 March 2026).
- Regulation (EU) 2022/2065 (Digital Services Act), Article 40, and the delegated regulation on data access (2025).
- UK Online Safety Act 2023 and Ofcom guidance on age assurance. Australia, Online Safety Amendment (Social Media Minimum Age) Act 2024.
- Wikimedia, API rate limits (2026).
