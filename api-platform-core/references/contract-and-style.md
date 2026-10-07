# 1. Contract and style

The contract is everything a consumer can observe. With enough consumers, every observable behaviour is depended on by somebody (Hyrum's Law). Design as if that is already true.

## Checklist

- [ ] A machine-readable contract exists and is the source of truth: OpenAPI 3.1 or 3.2 for HTTP, a schema for GraphQL, Protobuf for gRPC, AsyncAPI for events.
- [ ] The contract is checked in, reviewed with the code, and served from a stable URL.
- [ ] A linter enforces the house style in CI (for example Spectral for OpenAPI, buf lint for Protobuf).
- [ ] A breaking-change detector runs in CI against the last released contract (for example oasdiff, buf breaking). A breaking diff fails the build unless a new version is declared.
- [ ] Naming is consistent: one case style for fields, plural nouns for collections, the same word for the same thing everywhere.
- [ ] Every operation has an identifier, a summary, documented errors and at least one example.
- [ ] There is a written style guide, even a short one, and a named owner for exceptions.

## What counts as breaking

Treat all of these as breaking, even when they look harmless (Google AIP-180):

- Removing or renaming a field, an endpoint, an enum value or a parameter.
- Changing a type, a format, a unit or the meaning of a value.
- Adding a required request field, or making an optional one required.
- Changing a default value or default behaviour, including default page size and default sort order.
- Changing which errors are returned for a case a client could already hit.
- Tightening validation on input that used to be accepted.

One more, by Hyrum's Law rather than by AIP-180: adding a new enum value to a response. AIP-180 treats it as compatible, with a warning that clients may not handle it. In practice a client with an exhaustive switch breaks. It is safe only if the contract has always told clients to expect unknown values. Check how your breaking-change detector classifies this case. Some report it as a warning that does not fail the build.

Usually additive and therefore safer, but not automatically safe: a new endpoint, optional request field, response field, event type or optional header. Strict decoders may reject unknown fields, exhaustive switches may reject new enum values, and a new default or side effect can change behaviour without changing the schema. Run the contract diff, test representative real clients, and release risky changes to a small monitored slice with predefined rollback criteria.

## How to choose a protocol

- Public HTTP API for third parties: REST with JSON and OpenAPI. Widest reach, easiest to cache and to debug.
- Many internal services, strict schemas, high call volume: gRPC with Protobuf.
- Many different front ends reading overlapping data: GraphQL. Budget for query cost limits from day one.
- Notifying consumers that something happened: events and webhooks. See the events reference.
- Most large platforms mix these. Do not migrate protocols for fashion. Migrate when a measured cost justifies it.

## Governance that scales

Google's published model has three parts: written design proposals (AIPs), an automated linter, and trained reviewers. Their own study found that producers credit the process with more consistent APIs. The cheapest part to adopt is the automated check. Start there.

## Sources

- Hyrum's Law: https://www.hyrumslaw.com/
- Google AIP-180, Backwards compatibility: https://google.aip.dev/180
- Ahmad, Geewax, Macvean, Karger, Ma. API Governance at Scale. ICSE SEIP 2024.
- OpenAPI Specification 3.2 (2025): https://spec.openapis.org/oas/latest.html
- Microsoft Azure REST API guidelines; Zalando RESTful API guidelines.
