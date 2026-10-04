---
name: api-identity-provider
description: Reviews, designs and changes APIs that sign users in and issue tokens. Covers registration, login, passwords and passkeys, multi-factor authentication, sessions, OAuth 2 and OpenID Connect flows, token lifetimes and rotation, sender-constrained tokens, signing key rotation, account recovery, consent, and defences against enumeration, credential stuffing and takeover. Use when the project implements sign-in or an authorisation server, when the user mentions login, signup, password, passkey, WebAuthn, MFA, session, OAuth, OIDC, JWT, refresh token, PKCE, JWKS or account recovery, or when asked to make authentication safe.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Identity and sign-in APIs

Every other API trusts this one. A flaw here is a flaw in everything behind it. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the rules below.

## Ground rules

1. Prefer a maintained identity product or library to code written by hand. If the project has built its own cryptography, token format or password storage, say so first in the report.
2. Never change sign-in, token, session or recovery logic without the user's explicit go-ahead and tests for both the allowed and the refused case.
3. Never try credentials, guess passwords or probe a deployed environment. Assess by reading code and configuration.
4. When you find a password, a signing key, a client secret or a token in code or logs, report the file and line, never the value.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. If it reads live credentials, or points at any host that is not local or a named sandbox, do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format) keep that protocol's own errors, paging and status codes. Report a deviation from the protocol, not from this checklist.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can let someone take over an account, forge a token or lock users out), **Not applicable** (say why).

## Phase 1: Inventory

- The ways to sign in: password, passkey, social or enterprise login, magic link, one-time code.
- Second factors and when they are required.
- Sessions and tokens: their kinds, lifetimes, storage and revocation.
- OAuth and OpenID Connect: which flows are enabled, which clients exist and of what type.
- Signing keys: where they are held and how they rotate.
- Recovery: every way to get into an account without the usual credential.
- Machine identities: service accounts, API keys, agents.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Is recovery weaker than sign-in?** The easiest path into an account sets its real strength.
2. **How does a resource server validate a token?** Look for missing checks on signature, algorithm, issuer, audience and expiry.
3. **What does a stolen refresh token allow, and for how long?** Look for rotation, reuse detection and binding.
4. **Can responses tell an attacker which accounts exist?** Compare the answers and the timing for a real and an unknown user.
5. **What stops a million guesses?** Look for limits per account, per source and overall, not only one of them.

## Phase 3: Report

Lead with anything that allows account takeover or token forgery. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. Changes here can lock users out, so each one has a rollout plan and a way back.

- **Flows**: authorisation code with PKCE for every client. No implicit flow. No password grant. On an existing server, measure which clients use each flow first, then retire it with notice. Switching a flow off breaks live clients.
- **Protocol endpoints**: OAuth and OpenID Connect endpoints keep the error format the specifications define (`{"error": "invalid_request"}` and so on). Do not convert them to another format.
- **Tokens**: short-lived access tokens with a narrow audience and scope; refresh tokens rotated on use, with reuse detection, and sender-constrained where possible.
- **Validation**: one library, used by every resource server, that checks signature, an allowlist of algorithms, issuer, audience and time.
- **Keys**: published at a JWKS address, rotated on a schedule with overlap, held in a key management system.
- **Sign-in**: passkeys offered; passwords stored with a modern, slow hash and checked against known breaches; step-up for sensitive actions.
- **Recovery**: as strong as sign-in, rate limited, announced to the account's existing contacts, and it revokes existing sessions.

## What this skill does not do

It is not a penetration test or a certification. It tells you where those are needed.
