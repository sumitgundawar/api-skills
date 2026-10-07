---
name: api-media-streaming
description: Reviews, designs and changes APIs for video, audio and live streaming products. Covers catalogue and metadata, entitlements, playback authorisation, signed URLs and tokens, DRM licences, manifests, content delivery networks, concurrent stream limits, resume positions, uploads and transcoding, live events and viewer spikes. Use when the project serves or ingests media, when the user mentions playback, stream, HLS, DASH, manifest, DRM, Widevine, FairPlay, CDN, transcode, entitlement, watch history or live event, or when asked to make a streaming API safe against content theft, credential sharing or a launch-night outage.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.1"
---

# Media and streaming APIs

In streaming, the API is the small, critical call before a very large, cacheable one. If the small call fails, nobody watches. Use Inventory → Assess → Report for a review. For a direct design, change or explanation, use only the relevant phases; the request already authorises its scoped work. If the `api-platform-core` skill is installed, use its workflow and general HTTP guidance, then this skill for the domain rules below.

## Ground rules

1. Never change entitlement, playback authorisation, DRM or regional restriction logic without the user's explicit go-ahead and a test.
2. Never put signing keys, DRM keys or CDN secrets in code, logs or your own output. If you find one, report the file and line, never the value.
3. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance, and only after the user agrees.
4. Do not fetch, copy or redistribute media you find. Use test assets.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose revenue, leak content or data, or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- Catalogue: title, season, episode, asset, rendition, rights window, region.
- Entitlement: subscription, purchase, rental, free tier, and where it is decided.
- The playback path: authorise, get manifest, get licence, fetch segments, send heartbeats.
- What is served by the API and what by the CDN, and how the CDN trusts a request.
- Ingest: upload, transcode, packaging, publish.
- Viewer state: resume position, history, profiles, downloads.
- Live: schedule, start, viewer spike, end, replay.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can someone without an entitlement play a title?** Follow the path. The manifest, the licence and the segments must each be bound to the decision.
2. **Can a playback URL be shared?** Look at the lifetime of signed URLs and what they are bound to.
3. **Does playback depend on calls that are not essential?** Look for recommendations, history or analytics on the path to pressing play.
4. **What happens when everyone presses play at once?** Look for per-request work that could be cached or precomputed, and for a retry storm after a blip.
5. **Can one account stream on unlimited devices?** Look for a concurrency rule that is enforced on the server.

## Phase 3: Report

Lead with anything that lets content leak or stops playback under load. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start when the user asks for a change, or after they choose a finding. The list below is the target for new endpoints. On an existing endpoint, prefer a compatible migration and report a breaking form as needing a new version and the user's agreement.

- **Authorise playback**: one call that checks entitlement, region and concurrency, and returns short-lived, bound tokens for the manifest and the licence.
- **Priority**: playback started by a person is critical. Prefetch, artwork, recommendations and analytics are shed first.
- **Heartbeats and positions**: batched, safe to repeat, last-writer-wins by event time, and never able to block playback.
- **Catalogue reads**: cacheable at the edge, varied by region and plan, with ETags.
- **Uploads**: resumable, checksummed, scanned, with transcoding as an asynchronous job that reports per-rendition status.
- **Live**: a waiting room or staged admission, precomputed responses, and jittered client retries.

## What this skill does not do

It does not give rights, licensing or broadcasting regulatory advice. It tells you where those reviews are needed.
