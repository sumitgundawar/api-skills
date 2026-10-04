# Media and streaming API checklist

## Catalogue and rights

- [ ] Availability is computed from rights windows and regions on the server. The client does not filter.
- [ ] Catalogue responses are cacheable, and the cache key includes region, plan and maturity setting where they change the result.
- [ ] Identifiers are stable across re-encodes. An asset and its renditions are separate from the title.
- [ ] Removal of a title when rights end is scheduled and reaches downloads and caches.

## Entitlement and playback authorisation

- [ ] Entitlement is decided on the server at play time, from one source of truth.
- [ ] The playback response carries short-lived tokens bound to the account, the asset and, where possible, the device or session.
- [ ] Manifest, licence and segment requests each verify a token. A leaked manifest address alone does not play. The token on segment requests is kept out of the cache key (a cookie, or a path prefix validated at the edge), or every viewer gets a cache miss.
- [ ] Signed URL or cookie lifetimes are minutes, not days, and are renewed during playback.
- [ ] Regional restriction is enforced at authorisation and at the CDN. It is treated as a hurdle, not as proof of location.
- [ ] Concurrent streams are limited on the server by heartbeat or session leases, with a clear error and a way to see and end other sessions. A lost heartbeat does not stop playback: the lease is bounded and fails open.

## DRM

- [ ] The licence server checks entitlement for every licence request. It does not trust that the player got a manifest.
- [ ] Licence duration, rental windows and offline rules are set in the licence, by policy.
- [ ] Each major platform's system is covered (Widevine, FairPlay, PlayReady), usually with common encryption so one set of files serves all.
- [ ] Keys are stored in a key management system, rotated for live, and never logged.
- [ ] Device security level decides the maximum quality, and that rule is on the server.

## Delivery

- [ ] Segments are immutable and cached for a long time. Manifests for live are cached for seconds.
- [ ] The origin is protected, so the CDN cannot be bypassed.
- [ ] There is more than one CDN, or a tested plan for losing one, and switching does not need an app release.
- [ ] Clients retry with backoff and jitter, and fall to a lower rendition before failing.

## Viewer state

- [ ] Resume positions and history are written by batched, idempotent heartbeats. Conflicts resolve by event time.
- [ ] These writes are best effort. Their failure never stops playback.
- [ ] Profiles, including children's profiles, restrict the catalogue on the server.
- [ ] Viewing history is personal data. It can be exported and erased. Some places have specific laws about it, such as the US Video Privacy Protection Act.

## Ingest

- [ ] Uploads are resumable and verified by checksum. Limits on size, duration and format are enforced before work begins.
- [ ] Transcoding is an asynchronous job with a status per rendition, safe to retry, with capacity limits per uploader.
- [ ] Files are treated as hostile input: parsers run sandboxed, and metadata is stripped or validated.
- [ ] User uploads go through moderation and rights checks before they are public, with a takedown path.
- [ ] Publishing is an explicit step that is atomic from the viewer's side.

## Live and spikes

- [ ] The play path is load tested at the expected peak, including the login and entitlement calls behind it.
- [ ] Responses that are the same for everyone are precomputed or cached at the edge.
- [ ] Admission is staged if demand exceeds capacity.
- [ ] Requests carry a priority set at the edge. Playback is critical. Prefetch and analytics are shed first. Netflix reported keeping user-initiated playback above 99.4 percent available by shedding prefetch during a surge.
- [ ] After a failure, clients do not all retry at once.

## Abuse

- [ ] Credential stuffing defences cover login. Account sharing rules are enforced by policy, on the server.
- [ ] Catalogue scraping and automated ripping are expected. Token issue is rate limited per account and device.
- [ ] Watermarking, where used, can trace a leak to a session.

## Sources

- RFC 8216 (HTTP Live Streaming); ISO/IEC 23009-1 (MPEG-DASH); ISO/IEC 23001-7 (Common Encryption).
- W3C Encrypted Media Extensions.
- Netflix Tech Blog, Enhancing Netflix reliability with service-level prioritized load shedding (2024).
- OWASP API Security Top 10 (2023).
