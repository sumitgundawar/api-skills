# Audit report template

Fill this in and put it in your reply. Keep it to what you can support with evidence.

## Summary

One paragraph: what the API is for, how many endpoints you looked at, and the overall state in plain words.

## The three findings that matter most

For each one:

- **Finding**: one sentence.
- **Evidence**: file and line, or the request and response you observed.
- **Consequence**: what goes wrong, for whom, and how badly.
- **Smallest fix**: the least change that removes the risk.
- **Breaking?**: yes or no. If yes, what consumers must do.

## Scorecard

| # | Decision | Rating | Evidence | Next step |
|---|----------|--------|----------|-----------|
| 1 | Contract and style | | | |
| 2 | Resource model | | | |
| 3 | Authentication | | | |
| 4 | Authorisation | | | |
| 5 | Idempotency | | | |
| 6 | Concurrency | | | |
| 7 | Pagination and queries | | | |
| 8 | Errors | | | |
| 9 | Events and webhooks | | | |
| 10 | Versions and retirement | | | |
| 11 | Limits and overload | | | |
| 12 | Caching and performance | | | |
| 13 | Observability | | | |
| 14 | Testing and sandboxes | | | |
| 15 | Agent readiness | | | |
| 16 | Access policy | | | |

Ratings: Sound, Gap, Risk, Not applicable.

## Endpoint inventory

| Method | Path | Auth | Changes state | Idempotency key | Paginated | Version | Notes |
|--------|------|------|---------------|-----------------|-----------|---------|-------|

## What was not checked

List everything you could not verify: tests you could not run, environments you could not reach, code paths you did not read, and any behaviour you inferred.

## Suggested order of work

Number the fixes. Put anything that can lose money or data first. Mark each as additive or breaking.
