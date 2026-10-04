# 15. Agent readiness

A growing share of callers are AI agents acting for a person or a business. They retry more, run in parallel, cannot browse a documentation site efficiently, and act on exactly what your responses say. Design for them on purpose.

Status note: several items below rest on drafts or young standards. Each is marked. Adopt the stable ones first.

## Checklist, in five layers

### Discover

- [ ] `/.well-known/api-catalog` lists your APIs and links to their descriptions (RFC 9727, stable). Serve it as a link set, `application/linkset+json` (RFC 9264). Do not invent a format.
- [ ] `/llms.txt` gives a short index of your documentation for language models (community convention, not a standard).
- [ ] If you run an MCP server, it is discoverable and described (server cards are a proposal under discussion).
- [ ] If you publish agent skills, there is an index at `/.well-known/agent-skills/index.json` (Cloudflare draft, version 0.2; Stripe publishes an index for its own skills).
- [ ] `Link` headers on the home page point to the above (RFC 8288).

### Understand

- [ ] The OpenAPI description is complete and current: every operation has an identifier, a summary, parameter descriptions, examples and error types.
- [ ] Multi-step flows are described, for example with Arazzo (OpenAPI Initiative, version 1.1), so an agent does not have to infer the sequence.
- [ ] Documentation pages are available as Markdown, either at a parallel URL or through `Accept: text/markdown`. In Cloudflare's own example one page fell from 16,180 tokens to 3,150, about 80 percent fewer.
- [ ] Field and operation names are meaningful words, not abbreviations or internal codes.

### Authenticate

- [ ] OAuth protected-resource metadata is published (RFC 9728, stable).
- [ ] Tokens for agents are short-lived, narrowly scoped, and name both the person and the agent.
- [ ] A program can obtain sandbox credentials without a person filling in a form.
- [ ] Signed bot requests are verified where your edge supports it (Web Bot Auth, published as an IETF working group draft on 1 September 2026; not an RFC).

### Act

- [ ] Every write is idempotent with a key. Agents retry.
- [ ] Errors are problem-details documents that say what to do next (RFC 9457, stable).
- [ ] Limits are cost-based, and responses say how much is left.
- [ ] Responses are compact by default, with pagination and field selection, because the caller pays for every token it reads.
- [ ] Identifiers come with human-readable names next to them, so the agent does not have to guess which object is which.
- [ ] If you expose tools (MCP), there are few of them and each maps to a task, not to an endpoint. Offer search plus execute rather than one tool per endpoint.
- [ ] Destructive operations support a dry run, and high-impact ones can require a human approval step.

### Pay

- [ ] If you charge automated callers, you can answer 402 Payment Required with machine-readable terms (x402 version 2 headers `PAYMENT-REQUIRED`, `PAYMENT-SIGNATURE`, `PAYMENT-RESPONSE`; Stripe also supports the Machine Payments Protocol). Young, moving quickly.

## Why a small tool surface

Every tool definition occupies the model's context before it does anything. Cloudflare reported that describing its 2,500 or more endpoints as individual tools would take about 1.17 million tokens, and that two tools (`search` and `execute`) reduced this to about 1,000. Anthropic reported a drop from 150,000 to 2,000 tokens in one example by letting the agent read tool definitions on demand as code.

## MCP notes

- The 2026-07-28 revision of the Model Context Protocol made the core stateless: no initialise handshake, no session header, and any request can be served by any instance behind a plain load balancer.
- It also hardened authorisation and set a minimum of 12 months between deprecating a feature and removing it.
- An MCP server is a thin layer in front of your API. Everything else in this skill still has to be true behind it.

## Measure it

Segment agent traffic in your analytics. Track tokens per successful task if you can observe it, tool calls per task, error rate by error type, and retry rate. Cloudflare's Agent Readiness scan of the top 200,000 domains (April 2026) found that 3.9 percent served Markdown on request and fewer than 15 sites published an API catalog or MCP server card. The bar is low.

## Sources

- RFC 9727 (api-catalog), RFC 9728, RFC 9457, RFC 8288, RFC 9421.
- Cloudflare: Introducing the Agent Readiness score (April 2026); Markdown for Agents; Code Mode (2026); agent-skills-discovery-rfc.
- Anthropic Engineering: Writing effective tools for agents; Code execution with MCP.
- Model Context Protocol specification, 2026-07-28.
- OpenAPI Initiative: OpenAPI 3.2, Arazzo 1.1.
- x402 specification; Stripe docs, Machine payments.
- Postman, 2025 State of the API report.
