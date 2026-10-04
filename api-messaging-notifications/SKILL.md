---
name: api-messaging-notifications
description: Reviews, designs and changes APIs that send email, SMS, push notifications, in-app messages or chat. Covers send requests, templates, scheduling, delivery status, consent and opt-out, preferences, quiet hours, sender reputation and authentication, one-time passcodes, fan-out and provider failover. Use when the project sends messages to people, when the user mentions notification, email, SMS, push, OTP, verification code, template, campaign, unsubscribe, bounce, deliverability, Twilio, SendGrid, FCM or APNs, or when asked to make a messaging API safe against duplicate sends, spam complaints or SMS fraud.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Messaging and notification APIs

A message cannot be unsent. Every bug in a messaging API is visible to a customer, and some of them cost money per message. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. Never send a message to a real person. Use the provider's test numbers, a sink address or a sandbox, and only after the user agrees.
2. Never change consent, opt-out or suppression logic without the user's explicit go-ahead and a test.
3. Never send requests to production or to any shared environment. Assess by reading code and tests.
4. Message content and recipient addresses are personal data. Keep them out of logs and your own output.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can cost money, break the law on consent, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- Channels and providers, and what each costs per message.
- Kinds of message: transactional, security (codes, alerts), marketing. The rules differ for each.
- The send path: request, template, preference check, queue, provider, status callback.
- Where consent, preferences and suppression lists live.
- Who can trigger a send: a user action, an internal service, a customer of your API.
- What comes back: delivered, bounced, complained, replied, unsubscribed.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can a retry send the same message twice?** Follow a send through a timeout between your service and the provider.
2. **Can a message reach someone who opted out?** Look for a send path that skips the suppression check.
3. **Can a stranger make you send SMS at your cost?** Look for a code or invitation endpoint with no limits. This is SMS pumping fraud.
4. **Can one caller's bulk send delay a password reset?** Look for one queue shared by marketing and security messages.
5. **Can template input change the message?** Look for user-supplied values placed into subjects, links or HTML without escaping.

## Phase 3: Report

Lead with anything that can send to the wrong people, send twice at scale, break consent law or run up a bill. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Send**: accepts an idempotency key; returns a message resource with a state; checks consent and suppression at send time, not at request time.
- **Queues**: separate lanes for security, transactional and bulk, with security first.
- **Status**: provider callbacks verified, deduplicated and mapped to your own states; exposed by webhook and by read.
- **Codes**: short-lived, single use, limited per recipient, per source and per destination country.
- **Bulk**: an asynchronous job with a per-recipient result, a rate the provider accepts, and a stop button.
- **Unsubscribe**: one step, effective immediately, honoured on every channel it covers.

## What this skill does not do

It does not give legal advice on marketing consent or telecoms rules. It tells you where those reviews are needed.
