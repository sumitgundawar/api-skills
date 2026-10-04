# Mobile backend API checklist

## Old versions

- [ ] Requests carry the app identifier, version, build and platform, and these are logged.
- [ ] Usage by app version is on a dashboard. Nobody guesses which versions are alive.
- [ ] There is a written policy for how long a released version is supported.
- [ ] The server can answer "upgrade required" with a specific, documented response, and every released build handles it. If older builds do not handle it, that cannot be fixed afterwards: report the oldest build that obeys it as a permanent constraint.
- [ ] A softer "upgrade recommended" signal exists.
- [ ] Contract tests replay recorded requests from old versions against new server builds.
- [ ] New enum values, new fields and new error codes are safe for old clients. The apps are written to ignore what they do not know.
- [ ] Response fields are never changed from always present to sometimes absent without a version check.

## Networks

- [ ] Every state-changing request carries an idempotency key that survives retries, backgrounding and an app restart.
- [ ] Clients retry with backoff and jitter, and only where the server says it is safe.
- [ ] Timeouts are set for mobile conditions, and requests carry a deadline the server can see.
- [ ] The server tolerates a request arriving long after the user acted, and uses the action's own timestamp where order matters.
- [ ] Uploads are resumable.
- [ ] Responses are compressed and support conditional requests with ETags.

## Shape and size

- [ ] Screens that need several resources get them in one call, through a backend for frontend or a query language, not through ten sequential calls.
- [ ] Lists are cursor paginated with a server-set maximum.
- [ ] Images are served in the size and format the device asks for.
- [ ] The backend for frontend holds no business rules of its own. They live in the services behind it.
- [ ] The backend for frontend passes the caller's identity to the services behind it, which check authorisation themselves.

## Offline and sync

- [ ] Records carry a version or a change token. Sync is incremental from a cursor.
- [ ] Offline changes are sent as operations with the version they were based on. The server rejects or merges conflicts by a written rule and tells the client.
- [ ] Deletes are tombstones kept long enough for every device to see them.
- [ ] A device that has been offline for longer than the tombstone period does a full resync.
- [ ] Identifiers created offline are generated on the device and accepted by the server.
- [ ] Device clocks are not trusted for ordering between devices.

## Trust

- [ ] Every rule is enforced on the server: prices, limits, roles, feature access, validation.
- [ ] No secret that matters is in the app binary. Third party keys are held on the server, or are restricted to the app's identity.
- [ ] Access tokens are short lived. Refresh tokens are rotated, bound to the device where possible, and stored in the platform's secure storage.
- [ ] Logging out, a password change and a lost device revoke tokens on the server.
- [ ] App attestation (App Attest on iOS, Play Integrity on Android) is used as one signal for sensitive actions, with a fallback for devices that cannot attest.
- [ ] Certificate pinning, if used, has a rotation plan and a backup pin, so an expired certificate does not lock every user out.
- [ ] Deep links and universal links validate their parameters and never carry credentials.

## Push

- [ ] Device tokens are stored per device and per user, refreshed when the app reports a new one, and deleted on logout and when the push service says they are invalid.
- [ ] Push payloads carry an identifier and little else. The app fetches the content, so nothing sensitive sits on a lock screen.
- [ ] Sending the same notification twice is harmless: a collapse key or a notification identifier.
- [ ] Notification preferences are held on the server.

## Purchases

- [ ] Purchase receipts or tokens are verified by the server with the app store before anything is granted.
- [ ] Granting is idempotent on the store's transaction identifier.
- [ ] Server notifications from the stores drive renewals, refunds and revocations.
- [ ] A purchase is tied to an account, and restoring on a new device works.

## Flags and configuration

- [ ] Remote configuration can turn off a broken feature without a release.
- [ ] Flags are evaluated on the server where they affect access or price.
- [ ] Old flags are removed, so the number of contract variants stays bounded.

## Privacy

- [ ] The data each endpoint returns is the minimum the screen needs.
- [ ] Analytics and crash reports sent through your API carry no secrets or personal content.
- [ ] Location, contacts and photos are sent only with consent and only when needed.

## Sources

- Apple documentation: App Attest and DeviceCheck; App Store Server API and Server Notifications.
- Android documentation: Play Integrity API; Google Play Developer API and Real-time developer notifications.
- OWASP Mobile Application Security Verification Standard; OWASP API Security Top 10 (2023).
- RFC 8252 (OAuth 2.0 for native apps).
