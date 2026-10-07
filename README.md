# API skills

Twenty-two agent skills for building APIs that survive change, load and automated callers. They accompany the talk "Designing APIs and Integrations That Don't Fall Apart at Scale" (JAX London, 7 October 2026).

A skill is a folder with a `SKILL.md` file that a coding agent reads when a task matches. The format is the open Agent Skills format described at https://agentskills.io. It is read by many agent tools, including Claude Code, Codex, GitHub Copilot, Cursor and Gemini CLI.

## What is here

| Skill | Use it for |
|-------|-----------|
| [api-platform-core](api-platform-core/) | Any HTTP API. Sixteen decisions, an audit workflow, a report template and a route finder. |
| [api-ai-agents](api-ai-agents/) | APIs built for or consumed by AI agents: tools, MCP, budgets, identity, payment. |

By industry:

| Skill | Use it for |
|-------|-----------|
| [api-ecommerce](api-ecommerce/) | Shops: carts, stock, checkout, payments, orders, agent checkout. |
| [api-marketplace](api-marketplace/) | Two-sided platforms: seller onboarding, split payments, payouts, disputes, reviews. |
| [api-fintech-banking](api-fintech-banking/) | Money: ledgers, balances, transfers, open banking, reconciliation, audit. |
| [api-healthcare](api-healthcare/) | Health records: FHIR, SMART on FHIR, consent, audit, clinical safety. |
| [api-elearning](api-elearning/) | Learning platforms: rosters, launches, submissions, grades, learner privacy. |
| [api-social-media](api-social-media/) | Social and community platforms: graph, feeds, moderation, age, external access. |
| [api-travel-booking](api-travel-booking/) | Reservations: search, quotes, holds, booking, changes, supplier integrations. |
| [api-logistics-delivery](api-logistics-delivery/) | Shipping and fleets: labels, tracking events, field devices, carriers. |
| [api-media-streaming](api-media-streaming/) | Video and audio: entitlements, playback tokens, DRM, uploads, live spikes. |
| [api-iot-devices](api-iot-devices/) | Connected devices: identity, telemetry, commands, firmware updates, reconnects. |

By kind of API:

| Skill | Use it for |
|-------|-----------|
| [api-graphql](api-graphql/) | GraphQL: schema, cost limits, field-level access, evolution, federation. |
| [api-grpc-services](api-grpc-services/) | gRPC and internal services: proto compatibility, deadlines, retries, identity. |
| [api-webhooks-events](api-webhooks-events/) | Events: webhooks out and in, queues, the outbox, schemas, replay. |
| [api-mobile-backend](api-mobile-backend/) | Installed apps: old versions, offline sync, push, attestation, purchases. |
| [api-file-storage](api-file-storage/) | Files: signed and resumable uploads, validation, processing, downloads. |
| [api-data-analytics](api-data-analytics/) | Reports and data: long jobs, exports, ingestion, row-level access, cost. |

Shared services:

| Skill | Use it for |
|-------|-----------|
| [api-identity-provider](api-identity-provider/) | Sign-in and tokens: passkeys, OAuth, OpenID Connect, recovery, key rotation. |
| [api-saas-multitenant](api-saas-multitenant/) | Business software: tenant isolation, roles, SSO, SCIM, noisy neighbours. |
| [api-subscription-billing](api-subscription-billing/) | Billing: plans, usage metering, proration, invoices, entitlements. |
| [api-messaging-notifications](api-messaging-notifications/) | Email, SMS and push: idempotent sends, consent, delivery status, code fraud. |

Start with `api-platform-core` and add the ones that match your product. Several can be installed together.

The skills choose the smallest workflow that fits the request. A review uses **Inventory → Assess → Report**. A design task starts from constraints and produces a contract plus trade-offs. An implementation request inspects the affected contract, code, tests and callers, then makes and verifies the scoped change. An explanation answers directly. They never change code unless asked, and never break a contract silently.

Use `api-platform-core` for cross-cutting HTTP behaviour, then add a specialist only when its domain is central to the task. `api-webhooks-events` owns event delivery, `api-identity-provider` owns building an identity or authorisation server, and `api-ai-agents` owns agent-specific tools, delegation and inference. A protected API that merely uses OAuth still starts with the core skill.

## Install

Copy the folders you want into the place your agent looks for skills. For example:

```sh
git clone https://github.com/sumitgundawar/api-skills.git

# Claude Code, for one project
mkdir -p .claude/skills && cp -R api-skills/api-platform-core .claude/skills/

# Claude Code, for all your projects
mkdir -p ~/.claude/skills && cp -R api-skills/api-platform-core ~/.claude/skills/
```

Other tools use other folders. See your tool's documentation, or the list at https://agentskills.io.

Then ask your agent something like:

- "Audit this API with the api-platform-core skill and give me the report."
- "Add an idempotency key to the create order endpoint."
- "Plan the retirement of the v1 endpoints."
- "Is our checkout safe against a double charge?"

## Read before you run

A skill is a set of instructions that an agent will follow. Read these files before you install them, as you would read any dependency. The only script here is `api-platform-core/scripts/find-routes.sh`. It runs `find` and `grep` over your project and prints what it finds. It creates no files and sends nothing.

## Change them

These are a starting point. Your organisation has its own rules, names and limits. Fork the repository and edit the checklists to say what you actually do. A skill that matches your house style is worth more than one that is merely correct.

## Sources and dates

Every reference file lists its sources. The core, e-commerce, fintech, multi-tenant SaaS, subscription billing, messaging, webhook/event, identity, GraphQL, gRPC and AI-agent guidance was reviewed against the final JAX London material on 7 October 2026. The remaining skills were checked between 1 and 4 October 2026 from the standards they cite and have had an independent review. Check a cited standard yourself before you rely on a detail. Several agent-related standards are drafts and will change; each file says which.

## Licence

MIT. See [LICENSE](LICENSE).
