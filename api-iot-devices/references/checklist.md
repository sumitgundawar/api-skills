# IoT and device API checklist

## Identity and provisioning

- [ ] Every device has its own credential. There are no fleet-wide shared keys or default passwords. Universal default passwords are banned for consumer devices in the UK (the PSTI regime) and prohibited by provision 5.1 of ETSI EN 303 645.
- [ ] Device certificates and the trust anchors on the device have expiry dates that are tracked, and a renewal path that works in the field. A device with no reliable clock has a defined way to validate certificates.
- [ ] Private keys are generated on the device or injected in a controlled factory step, and are kept in secure hardware where it exists.
- [ ] The platform takes the device's identity from the authenticated connection (a client certificate or a token), never from a field in the payload.
- [ ] A device can publish and subscribe only to its own topics.
- [ ] Credentials can be rotated and revoked per device, and a revoked device is disconnected.
- [ ] Binding a device to an owner needs proof of possession (a code on the device, a button press). Transfer and factory reset remove the old owner's access and data.

## Telemetry

- [ ] Messages carry a device timestamp, a sequence number and a schema version.
- [ ] Ingestion deduplicates on device and sequence, and accepts late and out-of-order data.
- [ ] Device clocks are checked against server time, and large skews are flagged.
- [ ] Ingestion writes to a queue or a log first. A slow consumer does not push back on devices.
- [ ] Devices buffer while offline, with a cap and a rule for what to drop.
- [ ] Payloads are validated and size limited. A device is an untrusted client.
- [ ] Per-device and per-customer rate limits exist, so one faulty unit cannot flood the pipeline.

## Commands

- [ ] Each command has an identifier, an expiry and a target version of state where relevant.
- [ ] The device acknowledges receipt and result separately, and ignores a command identifier it has already run.
- [ ] Commands to an offline device are queued with a time to live, not forever.
- [ ] The app-facing API returns a command resource with a state (queued, delivered, done, failed, expired). It does not block waiting for the device.
- [ ] Safety-relevant commands have limits enforced on the device, not only in the cloud.

## Device state

- [ ] Desired state and reported state are separate, each with a version, so an app and a device cannot overwrite each other.
- [ ] Reads of state say when the device last reported.
- [ ] A device that has been offline reconciles on reconnect from the current desired state, not by replaying every missed change.

## Firmware updates

- [ ] Images are signed. The device verifies the signature and the version before installing, and refuses a downgrade unless it is explicitly allowed.
- [ ] Updates keep a known-good image, and the device rolls back if the new one fails to start or to reconnect.
- [ ] Rollout is staged by percentage and by cohort, with health checks and an automatic halt.
- [ ] Downloads are resumable and scheduled, so the fleet does not fetch at once.
- [ ] The platform knows the firmware version of every device, and the API can report it.
- [ ] There is a published support period for security updates, and a way to report vulnerabilities. The EU Cyber Resilience Act makes both obligations for products sold in the EU from 11 December 2027. Separately, from 11 September 2026 manufacturers must notify the authorities of actively exploited vulnerabilities and severe incidents.

## Connections and load

- [ ] Firmware reconnects with exponential backoff and jitter. A fixed interval is a finding.
- [ ] The broker or gateway limits connection rate and sheds new connections before it falls over.
- [ ] Keep-alive intervals suit the network and the battery.
- [ ] Work done on connect (authorisation, state sync) is cheap or cached.
- [ ] A regional outage and recovery has been tested with a realistic fleet size.

## The app and integrator API

- [ ] Every endpoint checks that the caller owns or is shared the device (OWASP API1).
- [ ] Sharing access (family, installer, support) is a grant with a scope and an end.
- [ ] Device identifiers in addresses are not guessable serial numbers used as the only check.
- [ ] History queries are cursor paginated, bounded in range, and offered as an asynchronous export for large spans.
- [ ] Integrations with voice assistants and smart-home platforms use scoped, revocable tokens.

## Privacy

- [ ] Data that reveals presence, location, health or habits is identified as personal and minimised.
- [ ] Customers can export and erase their data, including data held against a device they have sold.
- [ ] Cameras and microphones have indicators and server-side access logs.

## Compatibility

- [ ] The device protocol is versioned, and the server supports every version still in the field.
- [ ] Unknown fields are ignored by both sides, so new firmware and old servers can mix.
- [ ] End of support for a device is announced in advance, and says what stops working.

## Sources

- OASIS MQTT Version 5.0; RFC 7252 (CoAP).
- ETSI EN 303 645 (consumer IoT security baseline).
- UK Product Security and Telecommunications Infrastructure Act 2022 and its 2023 regulations.
- Regulation (EU) 2024/2847 (Cyber Resilience Act).
- RFC 9019 (a firmware update architecture for IoT).
- OWASP API Security Top 10 (2023); OWASP IoT Top 10.
