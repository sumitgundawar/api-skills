---
name: api-healthcare
description: Reviews, designs and changes APIs for health and care software. Covers patient records, appointments, prescriptions, results, clinical documents, FHIR and SMART on FHIR, consent, audit, break-glass access, integration with clinical systems, and patient safety. Use when the project stores or exchanges health data, when the user mentions patient, clinician, EHR, EMR, FHIR, HL7, SMART, prescription, referral, appointment, HIPAA or NHS, or when asked to make a health API safe against wrong-patient errors, data leaks or lost clinical messages.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# Healthcare APIs

A health API can hurt someone in two ways: by exposing a record, or by showing a clinician the wrong or a stale one. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. Never use real patient data. Not in tests, fixtures, logs, prompts or your own output. If you find real patient data in the repository, stop and report the file and line, never the content.
2. Never change code that affects identity matching, medication, results, allergies or clinical decision logic without the user's explicit go-ahead, a test, and a note that a clinical safety review is needed.
3. Never send requests to a deployed environment. Assess by reading code and tests. Make requests only against a local or sandbox instance with synthetic patients, and only after the user agrees.
4. Access is denied by default. Every read of a record is tied to a purpose and is logged.
5. A clinical record is corrected by amendment. It is not silently overwritten or hard deleted.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can harm a patient, lose data, leak data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- The people: patient, clinician, administrator, carer or proxy, external system.
- The records: demographics, encounters, observations and results, medications, allergies, documents, appointments.
- Identity: how a patient is identified and matched across systems, and what happens on a merge.
- Interfaces: FHIR, HL7 version 2 messages, documents, vendor APIs, and which side owns each field.
- Consent and the legal basis for each kind of access.
- The audit trail: what is recorded for a read, and who can see it.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can a caller read a patient they have no relationship with?** Check each handler for a check on the patient, the caller's role and the purpose, not only a valid token.
2. **Can a result be attached to the wrong patient?** Follow identity matching and merges. Look for matching on name or date of birth alone.
3. **Can a clinician act on stale data without knowing?** Look for caches and copies with no "last updated" shown and no version check on write.
4. **Is every read recorded?** Look for record views that produce no audit entry.
5. **What happens to a message that fails?** Look for inbound results or referrals that are dropped, retried forever, or applied twice.

## Phase 3: Report

Lead with anything that can harm a patient or expose a record. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check, and which findings need a clinical safety officer.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Read a record**: scoped to patient and purpose; returns when each item was last updated and where it came from; writes an audit entry.
- **Write clinical data**: versioned with `If-Match`, so two clinicians cannot overwrite each other; amendments keep the history; conditional create (`If-None-Exist`) on a FHIR interface and an idempotency key elsewhere, so a retried prescription is not issued twice.
- **Inbound messages**: acknowledged only once stored; deduplicated on the sender's message identifier; failures go to a queue a person can see, never to nowhere.
- **Third party apps**: SMART on FHIR scopes that name the patient and the resource types; short-lived tokens; no bulk access from a single-patient launch.
- **Bulk export**: asynchronous, authorised separately, logged, and limited to named recipients.
- **Break-glass**: an explicit, reasoned, time-limited override that alerts someone.

## What this skill does not do

It does not give clinical, legal or regulatory advice, and it is not a clinical safety assessment. It tells you where those reviews are needed.
