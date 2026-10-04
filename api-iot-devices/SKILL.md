---
name: api-iot-devices
description: Reviews, designs and changes APIs for connected devices and the platforms behind them. Covers device identity and provisioning, telemetry ingestion, commands, device state (twins or shadows), firmware updates, offline behaviour, fleet-wide reconnects, and the user-facing API on top. Use when the project talks to hardware, when the user mentions device, sensor, gateway, firmware, OTA, telemetry, MQTT, CoAP, provisioning, device twin, shadow or fleet, or when asked to make a device API safe against impersonation, command replay, bad updates or a reconnect storm.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# IoT and device APIs

A device is a client you cannot patch quickly, that will run its current firmware for years, and that reconnects at the same moment as every other device you sold. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. Never send a command, a configuration change or a firmware update to a real device. Assess by reading code. Use a simulator or a bench device, and only after the user agrees.
2. Never change provisioning, authentication, command or update logic without the user's explicit go-ahead and a test. A bad update can leave hardware unrecoverable.
3. Never send requests to a deployed environment or connect to a live broker. Assess by reading code and tests.
4. If a device can affect physical safety (heat, locks, motion, medical, vehicles), say so first in the report and recommend a safety review.
5. When you find device keys, certificates or shared secrets in code or firmware, report the file and line, never the value.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. If it reads live credentials, or points at any host that is not local or a named sandbox, do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format) keep that protocol's own errors, paging and status codes. Report a deviation from the protocol, not from this checklist.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can harm someone, damage devices, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- Device types, firmware versions in the field, and how long each is supported.
- Protocols: MQTT, HTTP, CoAP, a vendor cloud, and what sits between device and platform.
- Identity: how a device proves who it is, and how it got that credential.
- The message kinds: telemetry up, commands down, reported and desired state, firmware.
- Ownership: how a device is bound to a customer, transferred and wiped.
- The API that apps and integrators use, as distinct from the one devices use.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can one device pretend to be another?** Look for shared credentials, or identity taken from a field in the message.
2. **Can a command be replayed, or arrive hours late and still run?** Look for commands with no identifier and no expiry.
3. **Can a bad or forged firmware image be installed?** Look for signature checks on the device, staged rollout and rollback.
4. **What happens when the whole fleet reconnects?** Look for fixed retry intervals and work done per connection.
5. **Can a user control a device they do not own?** Check ownership on every app-facing endpoint, and what happens on resale.

## Phase 3: Report

Lead with anything that can harm a person, damage devices or let a stranger control one. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. Old firmware cannot be changed, so every change on the device side is additive and the old behaviour stays supported for its stated life.

- **Identity**: a unique credential per device, ideally a key that never leaves it; topics and endpoints authorised per device.
- **Telemetry**: batched, with a device timestamp and a sequence number; ingestion is idempotent and buffers through a queue.
- **Commands**: an identifier, an expiry and an acknowledgement; the device ignores a repeat; the API shows the command's state.
- **State**: desired and reported kept apart, each with a version.
- **Updates**: signed images, verified on the device, rolled out in stages, with automatic halt and rollback.
- **Reconnects**: exponential backoff with jitter in firmware, and admission control on the server.

## What this skill does not do

It does not give product safety, radio or cybersecurity certification advice. It tells you where those reviews are needed.
