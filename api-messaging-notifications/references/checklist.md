# Messaging and notification API checklist

## Send

- [ ] Send accepts an idempotency key, scoped to the caller. A repeat returns the first message.
- [ ] The response is a message resource with an identifier and a state (accepted, queued, sent, delivered, failed), not a bare success.
- [ ] The provider call carries your identifier, so a provider-side duplicate can be detected.
- [ ] A provider timeout leaves the message in an unknown state that a status check resolves. It is not blindly resent.
- [ ] Scheduled sends store the recipient's time zone and re-check consent when they fire.
- [ ] A message has an expiry. A login code that could not be delivered for an hour is dropped, not sent late.

## Consent and preferences

- [ ] Every message has a category, and the category decides which rules apply.
- [ ] Consent records say what was agreed, when, how and through which wording.
- [ ] The suppression list is checked at send time, for every path, including internal tools and bulk imports.
- [ ] Opt-out is honoured at once. Marketing email carries a one-click unsubscribe header (RFC 8058), which large mailbox providers require from bulk senders.
- [ ] SMS replies such as STOP are handled, and the provider's own opt-out list is synchronised with yours.
- [ ] Quiet hours and frequency caps are applied on the server, in the recipient's time zone, to marketing and non-urgent categories. Login codes and security alerts are exempt.
- [ ] A preference centre is exposed through the API, so every client shows the same choices.

## Templates and content

- [ ] Templates are versioned, and a message records the version it was rendered from.
- [ ] Variables are escaped for the channel. User-supplied text cannot inject HTML, headers, links or extra recipients.
- [ ] Links use your own verified domains. Open redirects are absent.
- [ ] Localisation falls back in a defined order.
- [ ] Sensitive content (codes, medical or financial detail) is kept out of push notification previews and email subjects.

## Delivery status

- [ ] Provider callbacks are verified by signature, deduplicated on the provider's event identifier, and accepted out of order.
- [ ] Hard bounces and complaints add the address to suppression automatically.
- [ ] Invalid push tokens are removed when the push service reports them.
- [ ] Status is offered by webhook, signed and replayable, and by a read endpoint.
- [ ] Delivery rates per provider, per channel and per destination are monitored, with alerts.

## Sender reputation

- [ ] Email domains publish SPF, DKIM and DMARC, and mail is aligned with them.
- [ ] Marketing and transactional mail use separate subdomains or streams, so one cannot damage the other.
- [ ] SMS senders are registered where the destination requires it (for example US 10DLC registration, or sender ID registration in several countries).
- [ ] New sending domains and addresses are warmed up gradually.

## One-time codes and security messages

- [ ] Codes are random, short lived, single use, and limited in attempts.
- [ ] Requests for a code are limited per recipient, per account, per source address and per destination country or prefix.
- [ ] Destinations with unusual cost or no business reason are blocked by default. SMS pumping fraud works by requesting codes to premium-rate ranges.
- [ ] Code endpoints do not reveal whether an account exists.
- [ ] Security messages have their own queue and capacity, and are never delayed by bulk sends.
- [ ] A fallback channel exists, and its use is itself rate limited.

## Fan-out and load

- [ ] Bulk sends are asynchronous jobs with progress, per-recipient results, pause and cancel.
- [ ] Sending rate respects each provider's limits, and backs off on their 429 responses.
- [ ] Provider failover is tested. Switching provider does not resend messages already accepted.
- [ ] A campaign that links to your site does not produce a spike your own API cannot serve. Sends are spread.

## If you offer messaging as an API to customers

- [ ] Each customer has its own limits, suppression list, sender identities and reputation isolation.
- [ ] Customers verify ownership of a domain or number before sending from it.
- [ ] Abuse detection covers spam and phishing sent through you, with a fast way to suspend a sender.
- [ ] Usage is metered idempotently, per message segment where the channel bills that way.

## Privacy

- [ ] Message bodies are kept only as long as needed, and that period is stated.
- [ ] Recipient addresses are masked in logs and dashboards.
- [ ] Erasure requests reach message history and provider logs where the provider allows it.

## Sources

- RFC 8058 (one-click unsubscribe); RFC 7208 (SPF); RFC 6376 (DKIM); RFC 9989 (DMARC, May 2026, which replaced RFC 7489).
- Google and Yahoo bulk sender requirements (2024).
- Apple Push Notification service and Firebase Cloud Messaging documentation.
- Twilio documentation: SMS pumping fraud; A2P 10DLC.
- UK PECR and EU ePrivacy rules on electronic marketing; US CAN-SPAM and TCPA.
