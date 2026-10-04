# 16. Access policy: who may call, and on what terms

Decide deliberately which callers you serve: people, known services, identified bots, anonymous automation. "Everyone, until it hurts" is a policy too, and an expensive one.

## The honest limit

Over HTTP you cannot prove that a person is present. You can prove that the caller holds a key, runs on an attested device, and is willing to bear a cost. Build from those three. Expect determined automation to get through any single control, and design so that what it gets is not worth much.

## Checklist

### Say it

- [ ] `robots.txt` states which automated uses you allow. It is a request, not a control.
- [ ] Usage preferences for AI are declared (Content Signals in `robots.txt`; the IETF AI Preferences vocabulary is still a draft).
- [ ] Terms of service and, where relevant, machine-readable licence terms (RSL 1.0) state what is permitted.

### Recognise the honest

- [ ] Verified bots are identified by signature (Web Bot Auth) or by the operator's published method, not by user agent string alone. A request signed by an operator you do not recognise is classified as unknown. Cache the key directory, and never fetch it inline from an address the caller chose.
- [ ] Unsigned automation is classified as unknown, with the lowest limits.
- [ ] Limits rise with the strength of identification. Wikimedia's 2026 API limits are a model: 10 requests a minute with no identification, 200 with a compliant user agent, 2,000 for established authenticated accounts.

### Bind the session

- [ ] Data endpoints require authentication. There are no anonymous endpoints that return valuable data in bulk.
- [ ] People sign in with phishing-resistant credentials (passkeys).
- [ ] Tokens are bound to the client: DPoP (RFC 9449) for APIs, device-bound session credentials in browsers that support them.

### Attest the client

- [ ] Mobile API calls carry platform attestation (Apple App Attest, Google Play Integrity), verified on the server.
- [ ] On the web, challenge suspicious traffic with a privacy-preserving token (Privacy Pass, RFC 9577 and 9578) or an equivalent managed challenge, not a picture puzzle.

### Shape the quota

- [ ] The human-facing API has limits sized for one person: small pages, modest rates, no bulk export.
- [ ] Bulk access exists only on a separate, contracted, metered API.
- [ ] Limits are per account and per entitlement, not only per IP address. Scrapers use large pools of residential addresses.

### Watch behaviour

- [ ] Connection fingerprints (TLS, HTTP/2 settings) and call patterns feed a risk score.
- [ ] Sudden changes in a known account's volume or sequence trigger a step-up challenge.

### Offer a paid door

- [ ] Automated callers that want access have a legitimate route: an API key and a contract, or pay per request with HTTP 402.
- [ ] The price and terms are machine-readable.

## What no longer works

- Picture puzzles. In 2024, researchers at ETH Zurich solved 100 percent of reCAPTCHA v2 image challenges with an object detection model.
- User agent strings and static IP lists. Both are trivially spoofed or rotated.
- Relying on anti-hacking law alone. In August 2026 the US Ninth Circuit vacated an injunction (stayed since March 2026) that would have kept an AI shopping agent off a retailer's site, reasoning that under the Computer Fraud and Abuse Act and California's equivalent statute it is the user who accesses the site when an agent acts on the user's instruction. Contract and tort claims were left open. Other jurisdictions differ. Take legal advice for your own case.

## The two-door design

- **Human door**: browser or first-party app, passkey, device-bound session, attestation, quotas sized for a person, no bulk.
- **Machine door**: declared identity, key or signature, metered, priced, with terms.

The aim is not to win an arms race at one door. It is to make the human door of little use to a bot and the machine door worth using.

## Fairness and safety

- Do not block assistive technology. Screen readers and accessibility tools are automation too. Test with them.
- Tell blocked callers why, and how to get access legitimately.
- Keep personal data out of fingerprinting, and document what you collect.

## Sources

- RFC 9309 (Robots Exclusion Protocol), RFC 9421, RFC 9449, RFC 9576 to 9578 (Privacy Pass).
- IETF draft-ietf-webbotauth-httpsig-protocol-00 (1 September 2026).
- Wikimedia APIs, Rate limits (2026); Wikimedia Diff, crawler traffic update (March 2026).
- Shopify Storefront API documentation (bots limited, most strictly when unsigned).
- Cloudflare: Your site, your rules (July 2026); Monetization Gateway (2026).
- Plesner, Vontobel, Wattenhofer. Breaking reCAPTCHAv2. 2024.
- Amazon.com Services v. Perplexity AI, 9th Cir., 4 August 2026.
- TollBit, State of the Bots (robots.txt bypass rates).
