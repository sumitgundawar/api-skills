# Checklist: APIs for AI agents

Facts and versions were checked in October 2026. Protocols in this area move quickly. Confirm against the current specification.

## Tool design

- [ ] The tool list is short. Each tool is a task an agent wants done, not a wrapper around one endpoint.
- [ ] Related operations are consolidated (for example one `schedule_event` rather than `list_users`, `list_events`, `create_event`).
- [ ] Names are namespaced and unambiguous. Descriptions state what the tool does, when to use it, what it returns and what it costs.
- [ ] Inputs have types, constraints and examples. Invalid input returns an error that says how to fix it.
- [ ] Outputs prefer names over bare identifiers, are paginated or truncated with a note on how to get more, and offer a concise mode.
- [ ] For a large API, tools are loaded on demand or replaced by search plus execute. Cloudflare reported about 1.17 million tokens to describe 2,500 or more endpoints as tools, against about 1,000 tokens with two tools. Anthropic reported 150,000 tokens reduced to 2,000 in one example.
- [ ] Tool definitions and behaviour are versioned, and changes follow the same compatibility rules as any API.
- [ ] There is an evaluation set of realistic tasks, and tool changes are measured against it.
- [ ] A repeat-sensitive tool scopes its idempotency key to principal plus operation, stores a request fingerprint, claims concurrent duplicates atomically and retains the result for the full retry horizon.

## MCP servers

- [ ] The server follows the current protocol revision. The 2026-07-28 revision removed the initialise handshake and the session header: every request carries its protocol version and capabilities, and any instance can serve any request.
- [ ] State that must persist is held behind an explicit handle passed as an argument, not in a protocol session.
- [ ] Requests carry the routing headers the revision requires, so gateways can route and meter without parsing bodies.
- [ ] List results declare how long they may be cached.
- [ ] Authorisation follows the specification: OAuth, protected-resource metadata (RFC 9728), issuer validation (RFC 9207), and client identity through Client ID Metadata Documents rather than open dynamic registration.
- [ ] The server never forwards a token it received to a downstream API. It obtains its own token for the downstream audience (token exchange, RFC 8693).
- [ ] Long work uses the Tasks extension or an equivalent task handle that can be polled, cancelled and resumed.
- [ ] Features the revision deprecated (roots, sampling, logging) are not relied on in new work. The old HTTP plus SSE transport has been deprecated since revision 2025-03-26.
- [ ] The server implements `server/discover`, every result carries `resultType`, and a tool that needs more input returns `input_required` for the client to retry with `inputResponses`. Check the current specification before claiming conformance.

## Identity and authorisation

- [ ] Each agent has its own identity. A person and an agent never share a key.
- [ ] Tokens are short-lived, narrowly scoped to the task, and name both the person and the agent.
- [ ] Discovery and description are not authority: RFC 9727 can locate an API and OpenAPI can describe it, but OAuth scopes and independent policy authorise actions and duration.
- [ ] The resource service still enforces tenant, permitted action and exact-object ownership or relationship on every call.
- [ ] An agent may request more authority but cannot approve it for itself. The approver, granted scope, expiry and revocation path are recorded outside the model.
- [ ] Consent screens tell the person which agent is asking and for what.
- [ ] High-impact actions require a fresh, explicit approval from a person, delivered out of band from the model.
- [ ] Every action is logged with the agent, the person, the tool, the arguments and the result.
- [ ] Credentials can be revoked per agent without affecting the person's other sessions.
- [ ] Agents that call your public endpoints can identify themselves with a signature (Web Bot Auth, an IETF working group draft as of September 2026), and you verify it where your edge supports it.

## Injection and data safety

- [ ] Untrusted content is clearly separated from instructions wherever it enters a prompt.
- [ ] When untrusted content is in context, tools that can send data out or change state are restricted or need approval.
- [ ] Tool descriptions and results from third parties are treated as untrusted. Hidden instructions in tool descriptions (tool poisoning) are a demonstrated attack.
- [ ] Outbound requests made by tools are restricted to allowed destinations (server-side request forgery, OWASP API7).
- [ ] Secrets are never placed in prompts or returned in tool results.
- [ ] Code that an agent writes runs in a sandbox with resource limits and no ambient credentials.
- [ ] Third-party MCP servers and skills are reviewed before installation and pinned to a version. Snyk's audit of 3,984 public skills in February 2026 found at least one security flaw in 36.8 percent, and confirmed 76 malicious payloads.

## Limits, cost and budgets

- [ ] Limits are expressed in the unit that reflects cost. For model APIs that is tokens a minute, input and output counted separately, alongside requests a minute.
- [ ] Responses report remaining quota. A caller-specific limit uses 429; service overload uses 503. Include `Retry-After` only when the estimate is credible.
- [ ] Overload (the service is saturated) is distinguished from rate limiting (this caller sent too much), so clients back off correctly.
- [ ] Each task has a budget for steps, tokens, wall-clock time and money, enforced in code outside the model.
- [ ] When several agents share one quota, a coordinator or a shared limiter prevents them from retrying in step.
- [ ] Retries use backoff with jitter and a retry budget. An agent that appends context on every retry is detected and stopped.
- [ ] Usage is metered per person, per agent and per task, and visible to the customer.

## Streaming and long-running work

- [ ] On your own HTTP API, streaming uses server-sent events with event identifiers, so a dropped connection can resume. This needs the server to buffer recent events.
- [ ] On MCP (revision 2026-07-28), a dropped stream is not resumed. The client re-issues the request, so state-changing tools are idempotent.
- [ ] Code written by a model and run by an `execute` style tool has a sandbox, a budget per execution (calls, time, cost) and an audit trail. One execution can be a thousand API calls.
- [ ] There is a clear terminal event, and errors mid-stream are delivered as events, not as a silent close.
- [ ] Long tasks return a handle immediately. Status, partial results, cancellation and expiry are all defined.
- [ ] Starting a task is idempotent.
- [ ] Results are retained for a stated period after completion.

## Agent to agent

- [ ] If agents call each other (A2A, version 1.0 since 2026), each publishes an agent card at `/.well-known/agent-card.json` describing its skills, modalities and authentication.
- [ ] Delegation narrows authority at each hop. It never widens it.
- [ ] The chain of who asked whom is recorded.

## Payment by agents

- [ ] If you charge per call, 402 Payment Required carries machine-readable terms. With x402 version 2 the server sends `PAYMENT-REQUIRED`, the client retries with `PAYMENT-SIGNATURE`, and the server answers with `PAYMENT-RESPONSE`.
- [ ] Spending limits are enforced per agent and per period, outside the model.
- [ ] Refunds and disputes have a defined path.
- [ ] Card payments by agents use scoped, expiring tokens, not card numbers.

## Observability

- [ ] Every tool call is traced with task, agent, person, tool, arguments size, result size in tokens, duration and outcome.
- [ ] Dashboards show tool calls per task, tokens per task, error rate by type and retry rate.
- [ ] Prompts and results are logged only as far as privacy rules allow, with redaction.

## If you serve model inference

- [ ] A generation request accepts an idempotency key or a client request identifier. A retried generation is otherwise new work and is billed twice.
- [ ] Token usage is reported in the response, and in the final event of a stream, so a caller can account for cost without counting tokens itself.
- [ ] The response says why generation stopped (finished, length limit, tool call, content filter), so a truncated answer is never mistaken for a complete one.
- [ ] Model names are pinned to a version. An alias that moves is documented as moving.
- [ ] Each model version has a published retirement date, announced in advance and signalled in responses. A model is an API version: the retirement runbook in `api-platform-core` applies.
- [ ] Limits are stated in tokens as well as requests, and the remaining budget is returned in headers.

## Sources

- Model Context Protocol specification, revision 2026-07-28, and its release notes.
- Anthropic Engineering: Writing effective tools for agents; Code execution with MCP.
- Cloudflare: Code Mode (2026); Web Bot Auth documentation.
- RFC 9728, RFC 9207, RFC 8693, RFC 9457, RFC 9421.
- A2A protocol, version 1.0.
- x402 specification, version 2. Stripe documentation, Machine payments and Shared Payment Tokens.
- Snyk, ToxicSkills (February 2026). Invariant Labs, tool poisoning (2025).
- OWASP API Security Top 10 (2023). OWASP Top 10 for LLM Applications. OWASP Top 10 for Agentic Applications.
- Postman, What Passport found in three weeks of AI agent traffic (September 2026).
