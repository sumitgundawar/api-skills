# Identity and sign-in API checklist

## Registration and sign-in

- [ ] Responses and timing do not reveal whether an account exists, on sign-in, registration and recovery alike.
- [ ] Email addresses and phone numbers are verified before they can be used to sign in or recover.
- [ ] Sign-in attempts are limited per account, per source address and globally, with increasing delay. A limit on one alone is not enough against credential stuffing.
- [ ] Account lockout cannot be used by a stranger to lock a user out for long.
- [ ] Automated sign-up and sign-in are detected and slowed (OWASP API6).
- [ ] Sign-in, failure, recovery and factor changes are logged with enough context to investigate, and without secrets.
- [ ] Users are told of new sign-ins and of changes to their credentials.

## Passwords

- [ ] Passwords are hashed with a slow, salted algorithm designed for the purpose (Argon2id, scrypt or bcrypt), with parameters that are reviewed. bcrypt ignores input beyond 72 bytes, so handle long passwords deliberately.
- [ ] Length is the main rule. There is a generous maximum, no composition rules and no forced periodic change, as NIST SP 800-63B advises.
- [ ] New passwords are checked against lists of breached passwords.
- [ ] Passwords never appear in logs, URLs or error messages.
- [ ] Changing a password requires the current one or a recent strong sign-in, and ends other sessions.

## Passkeys and second factors

- [ ] Passkeys (WebAuthn) are offered, and the server verifies the challenge, the origin and the signature counter or backup flags as the specification requires.
- [ ] A user can register more than one passkey, and can see and remove them.
- [ ] Second factors resist phishing where possible. SMS codes are treated as the weakest option.
- [ ] One-time codes are single use, short lived and limited in attempts.
- [ ] Adding or removing a factor requires a recent strong sign-in and notifies the user.
- [ ] Recovery codes are shown once and stored hashed.

## Recovery

- [ ] Recovery is at least as strong as sign-in. It does not bypass the second factor.
- [ ] Reset tokens are random, single use, short lived, stored hashed, and bound to the account.
- [ ] Reset links do not leak through referrer headers or logs.
- [ ] Recovery is rate limited per account and per source.
- [ ] A successful recovery ends existing sessions and tokens, and tells the account's contacts.
- [ ] Support staff cannot reset an account without a defined check, and their actions are logged.

## Sessions

- [ ] Session identifiers are long, random, and regenerated at sign-in and at privilege change.
- [ ] Browser sessions use cookies that are `Secure`, `HttpOnly` and `SameSite`, with defences against cross-site request forgery.
- [ ] Sessions have an idle limit and an absolute limit.
- [ ] Users can see their sessions and end them. Signing out ends the session on the server.
- [ ] Device-bound sessions are used where the platform supports them.

## OAuth and OpenID Connect

- [ ] The authorisation code flow with PKCE is used for every client type. The implicit flow and the resource owner password grant are off. This is the direction of RFC 9700 and the OAuth 2.1 draft.
- [ ] Redirect addresses are matched exactly against registered values.
- [ ] `state` or PKCE protects against cross-site request forgery, and `nonce` binds an ID token to the request.
- [ ] Authorisation codes are single use and live for seconds to a minute.
- [ ] Public clients (browser and mobile apps) hold no secret. Confidential clients authenticate with a private key or mutual TLS in preference to a shared secret.
- [ ] Native apps use the system browser, not an embedded web view (RFC 8252).
- [ ] The server publishes its metadata (RFC 8414, or OpenID Connect discovery), and returns the issuer in authorisation responses (RFC 9207) to prevent mix-up attacks.
- [ ] Consent screens name the client and the scopes plainly, and users can review and revoke grants.
- [ ] Input-constrained devices use the device authorisation grant (RFC 8628), with protection against a phished user code.
- [ ] Client registration is controlled. Open dynamic registration is a decision, with limits.

## Tokens

- [ ] Access tokens live for minutes, and name one audience and the smallest scope.
- [ ] Refresh tokens are rotated on every use. Reuse of an old one revokes the whole family. Allow a short grace window, or make the refresh idempotent, so a retry after a lost response on a poor connection is not treated as theft.
- [ ] Refresh tokens for public clients are sender-constrained (DPoP, RFC 9449) or rotated. Tokens for high-value APIs are bound by DPoP or mutual TLS (RFC 8705).
- [ ] Resource servers validate the signature, an allowlist of algorithms (never `none`, and no confusion between symmetric and asymmetric keys), the issuer, the audience, expiry and not-before, following RFC 8725.
- [ ] ID tokens are for the client. They are not accepted as access tokens by APIs.
- [ ] Tokens contain no secrets and the least personal data.
- [ ] Revocation works (RFC 7009), and there is a way to cut off a compromised user or client quickly despite self-contained tokens: short lifetimes, introspection (RFC 7662), or a revocation signal.
- [ ] A service that calls another on a user's behalf exchanges the token (RFC 8693) for a narrower one. It does not pass the user's token through.

## Signing keys

- [ ] Keys are generated and held in a key management system or hardware module. They are not in the repository or in environment files.
- [ ] Public keys are published at the JWKS address, each with a key identifier.
- [ ] Rotation is scheduled and rehearsed: publish the new key, sign with it, retire the old one after the longest token lifetime.
- [ ] Resource servers cache the key set, refresh on an unknown key identifier, and limit how often they do so.
- [ ] There is a tested procedure for emergency rotation.

## Machine identities

- [ ] Service accounts and API keys are separate from user accounts, scoped, stored hashed, shown once and rotatable.
- [ ] Keys carry a recognisable prefix, so leaked ones can be found by scanning.
- [ ] Agents acting for a user have their own identity and a token that names both the agent and the user.
- [ ] Workloads authenticate with platform-issued identities in preference to long-lived secrets.

## Availability

- [ ] Sign-in and token endpoints have reserved capacity and their own limits. An outage here is an outage everywhere.
- [ ] Resource servers keep working through a short outage of the identity service, by validating tokens locally with cached keys.
- [ ] Token endpoints are protected from retry storms after a failure. Clients refresh with jitter, not all at expiry.
- [ ] Dependencies such as SMS and email providers have fallbacks.

## Sources

- RFC 6749 and RFC 6750 (OAuth 2.0); RFC 7636 (PKCE); RFC 9700 (OAuth 2.0 security best current practice); the OAuth 2.1 draft.
- OpenID Connect Core 1.0 and Discovery 1.0.
- RFC 7519 (JWT); RFC 8725 (JWT best current practices); RFC 7517 (JWK).
- RFC 9449 (DPoP); RFC 8705 (mutual TLS); RFC 8693 (token exchange); RFC 7009 (revocation); RFC 7662 (introspection); RFC 8414 (server metadata); RFC 9207 (issuer identification); RFC 8628 (device grant); RFC 8252 (native apps).
- W3C Web Authentication (WebAuthn) Level 3.
- NIST SP 800-63B, Digital Identity Guidelines.
- OWASP Authentication, Session Management, Password Storage and Forgot Password Cheat Sheets; OWASP API Security Top 10 (2023).
