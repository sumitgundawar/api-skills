# 2. Resource model

Getting the nouns right early is cheaper than any later fix, because names and identifiers are the hardest parts of a contract to change.

## Checklist

- [ ] Resources are nouns from the consumer's domain, not tables from your database.
- [ ] Every resource has one stable, opaque identifier. Clients never parse it.
- [ ] Identifiers are not sequential integers. Use a random or time-ordered identifier (UUIDv7 from RFC 9562 sorts by creation time and indexes well). A short type prefix such as `ord_` or `cus_` makes logs and support far easier. A time-ordered identifier reveals when the object was created. Where that matters (user accounts, anything that should not be enumerable or dated), use a fully random identifier.
- [ ] Timestamps are RFC 3339 strings in UTC, or integer epoch seconds, and you use one of the two everywhere.
- [ ] Money is an integer in the smallest currency unit, or a decimal type where prices below one unit are needed, plus an ISO 4217 currency code. Never a float. The number of minor units differs by currency (the yen has none, the Kuwaiti dinar has three).
- [ ] Enumerations are strings, and the contract tells clients to tolerate values they do not recognise.
- [ ] "Absent", "null" and "empty" each mean one documented thing.
- [ ] Relationships are expressed as identifiers, with an explicit way to include the related object when asked.
- [ ] State machines are explicit. Each state is listed and each transition is an operation with rules, not a free-form field update.
- [ ] Long text, files and large collections are separate resources or separate endpoints, not inline blobs.
- [ ] Every resource carries `created` and `updated` times, and a version or ETag if it can be updated.

## Common mistakes

- Exposing database identifiers and column names. You have now published your schema.
- One endpoint that returns a different shape depending on a flag. Make it two endpoints.
- Boolean fields that later need a third state. Prefer an enum from the start.
- Nesting resources more than one level deep in the path. Prefer `/orders/{id}` over `/customers/{c}/orders/{o}/items/{i}` once an identifier is globally unique.
- Reusing a field for a new meaning. Add a new field and deprecate the old one.

## Sources

- RFC 9562, Universally Unique IDentifiers (2024).
- RFC 3339, Date and Time on the Internet.
- Google AIP-121 (resource-oriented design), AIP-122 (resource names), AIP-216 (states).
- Stripe API reference (prefixed identifiers, integer amounts, expandable objects).
