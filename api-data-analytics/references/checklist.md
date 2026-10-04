# Data and analytics API checklist

## Queries

- [ ] Every query has a bounded time range, a maximum number of rows, and a timeout enforced by the database as well as the API.
- [ ] Results are cursor paginated with a stable sort. Deep pages do not rescan.
- [ ] Filters, groupings and sort fields are an allowlist. Query text is never built from caller input (OWASP injection).
- [ ] If callers can send a query language, it runs with a restricted role, a cost estimate before execution, and a cap.
- [ ] Analytical queries run on a replica or a warehouse, not on the primary that serves user requests.
- [ ] Identical queries are cached, and the cache key includes the caller's access scope.
- [ ] A caller can cancel a running query, and cancelling stops the work in the database.

## Jobs and exports

- [ ] Anything that may take more than a few seconds is a job: create returns 202 and a job resource, with a state, progress and a result link.
- [ ] Creating a job accepts an idempotency key, so a retry does not start a second export.
- [ ] Jobs per caller are limited in number and in concurrency, and are queued fairly between tenants.
- [ ] Results are files in object storage behind short-lived signed links. They expire and are deleted.
- [ ] Completion is announced by webhook as well as by polling, and polling responses carry Retry-After.
- [ ] File formats are documented. CSV states its encoding, delimiter, quoting and how nulls appear. A typed format such as Parquet or JSON Lines is offered for machines.
- [ ] Values that begin with characters a spreadsheet treats as a formula are neutralised in CSV exports.
- [ ] Very large exports are split into parts with a manifest and checksums.
- [ ] An export applies exactly the same access rules as the equivalent query, and is logged with who asked and what they received.

## Ingestion

- [ ] Single events carry a unique identifier and are deduplicated on it.
- [ ] Batches carry a client-supplied batch identifier, and repeating a batch does not double the data.
- [ ] Each row is validated, and the response or the job result lists accepted and rejected rows with reasons. One bad row does not silently drop a batch or pass unnoticed.
- [ ] Large uploads are resumable, size limited and checksummed.
- [ ] Ingestion goes through a queue, so a burst does not reach the store directly.
- [ ] Late and out-of-order data has a rule, and corrections have a path that does not require a full reload.
- [ ] Events carry the time they happened and a time zone or offset, separate from the time they arrived.
- [ ] Per-caller quotas exist for volume as well as for request rate.

## Access

- [ ] Row-level rules come from the caller's identity and are applied in one place that every query, export, cache and embedded view goes through.
- [ ] Column-level rules hide or mask sensitive fields by role.
- [ ] Tenants cannot see each other's data in shared tables, caches or temporary result stores.
- [ ] Embedded dashboards use signed, short-lived tokens that carry the viewer's filters, and those filters cannot be edited in the browser.
- [ ] Service accounts used for scheduled reports have the rights of the report's owner, and lose them when the owner does.

## Aggregates and privacy

- [ ] Breakdowns have a minimum group size, and small groups are suppressed or merged.
- [ ] A caller cannot get round suppression by subtracting one query from another. Where it matters, rounding or noise is applied, and specialist advice is taken.
- [ ] Personal data in datasets is minimised, pseudonymised where possible, and covered by erasure and retention rules that also reach exports already produced.
- [ ] Free-text fields are treated as personal data.

## Definitions and freshness

- [ ] Each metric has one definition, in one place, with a name, a formula, a unit and an owner.
- [ ] A change to a definition is versioned and announced. The old definition is kept for a period.
- [ ] Every response states the time the data is complete up to, and whether recent periods are provisional.
- [ ] Time zone, week start and currency conversion rules are explicit parameters or documented defaults.
- [ ] Numbers that should agree across endpoints are tested to agree.

## Schema evolution

- [ ] Datasets have a published schema with types, nullability and descriptions.
- [ ] Columns are added, not renamed or retyped. Removal follows a notice period.
- [ ] Consumers are told that column order is not guaranteed, or it is guaranteed and tested.
- [ ] Schema checks run in CI against the published version.

## Cost and load

- [ ] Limits are on cost (bytes scanned, compute time), not only on request count.
- [ ] The response reports the cost of the query.
- [ ] Interactive queries have priority over scheduled and bulk work, which is shed or delayed first.
- [ ] Scheduled reports are spread out. They do not all start on the hour.
- [ ] Automated callers get bulk access on separate terms, so they do not page through the interactive API.

## Sources

- Google AIP-151 (long-running operations); AIP-158 (pagination).
- Shopify developer docs, Bulk operations. Salesforce Bulk API 2.0 documentation.
- OWASP API Security Top 10 (2023); OWASP CSV Injection.
- UK ICO, anonymisation guidance; Article 29 Working Party Opinion 05/2014 on anonymisation techniques.
- Apache Parquet format documentation; RFC 4180 (CSV).
