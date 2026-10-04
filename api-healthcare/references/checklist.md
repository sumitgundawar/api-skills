# Healthcare API checklist

## Identity and matching

- [ ] A patient has one stable internal identifier. National or insurer identifiers are attributes, not the primary key.
- [ ] Matching across systems uses a verified identifier or several attributes together, never name or date of birth alone.
- [ ] A merge of two records is an explicit, reversible, audited operation, and old identifiers keep resolving.
- [ ] Every screen and response that shows clinical data also carries enough demographics to confirm the patient.
- [ ] Test patients are synthetic and cannot be confused with real ones.

## Access control

- [ ] Each read and write checks the caller's role, their relationship to the patient and the purpose. A valid token alone is not enough (OWASP API1).
- [ ] Sensitive categories (for example sexual health, mental health, safeguarding) have additional restrictions.
- [ ] Proxy access (a parent, a carer) is its own grant, with a scope and an end date, and is reviewed when a child reaches the age your rules set.
- [ ] Break-glass access needs a stated reason, is time limited, and notifies a responsible person.
- [ ] Staff cannot browse records. Searches require enough detail to identify one patient.

## Audit

- [ ] Every read, write, export and failed attempt on a record is logged with actor, patient, purpose, time and source.
- [ ] The audit trail is append only and separate from the application's own database rights.
- [ ] A patient or a privacy officer can be shown who looked at a record.
- [ ] Logs and error messages contain identifiers, not clinical content.

## Clinical data integrity

- [ ] Writes use a version and `If-Match`. A lost update on a medication list is a patient safety incident. FHIR uses weak ETags (`W/"3"`) with `If-Match` by design, so do not report that as a fault.
- [ ] Search is authorised as well as read. Search parameters, `_include` and `_revinclude` cannot return another patient's resources.
- [ ] Creation of prescriptions, orders and referrals accepts an idempotency key.
- [ ] Records are amended, not overwritten. The previous value, the author and the time are kept.
- [ ] Units are explicit and coded (UCUM). Codes carry their system and version (SNOMED CT, LOINC, ICD, dm+d or RxNorm).
- [ ] Each item carries its source and when it was last updated, so a consumer can tell a stale copy.
- [ ] Times carry an offset. A date of birth is a date, not an instant.
- [ ] Deletion requests are handled under the rules for health records, which usually require retention. Take advice.

## Interoperability

- [ ] FHIR resources validate against the version and the profiles you claim (R4 is the most widely deployed; national profiles such as US Core or UK Core add rules).
- [ ] The capability statement at `/metadata` is accurate.
- [ ] SMART on FHIR app launch uses the published scopes, PKCE, and the discovery document at `/.well-known/smart-configuration`.
- [ ] Bulk export follows the FHIR Bulk Data pattern: asynchronous kick-off, status polling, file links that need the access token or are short lived, backend service authorisation.
- [ ] HL7 version 2 messages are acknowledged only after durable storage, and duplicates are detected on the message control identifier.
- [ ] Inbound messages that fail to parse or match go to a monitored queue with an owner.
- [ ] Subscriptions or webhooks carry a reference, not the clinical payload, where the channel is less trusted.

## Safety

- [ ] A hazard log exists for the API, and changes to clinical behaviour go through it. In England, DCB0129 applies to manufacturers of health IT and DCB0160 to the organisations that deploy it.
- [ ] Degraded states are visible. If results or allergies cannot be loaded, the response says so and does not return an empty list.
- [ ] Decision support that uses an AI model states that it does, records the model version, and keeps a person in the decision.
- [ ] There is a tested way to tell every consumer that data they received was wrong.

## Privacy and law

- [ ] The legal basis and the consent model are written down for each data flow.
- [ ] Data is encrypted in transit and at rest. Backups and analytics copies are in scope.
- [ ] Data sent for analytics or model training is de-identified to a stated standard, and re-identification risk has been assessed.
- [ ] Suppliers that process health data are under contract (a business associate agreement under HIPAA, a processor agreement under GDPR).

## Load and resilience

- [ ] Clinical reads and writes have reserved capacity. Reporting, exports and analytics are shed first.
- [ ] A slow external system (a lab, a national service) cannot exhaust your workers: timeouts, budgets and circuit breakers.
- [ ] There is a documented downtime procedure, and the API can replay what was captured during it.

## Sources

- HL7 FHIR R4 and R5; FHIR Bulk Data Access; SMART App Launch.
- US: HIPAA Privacy and Security Rules; ONC certification criteria for standardised APIs.
- UK: NHS England clinical risk management standards DCB0129 and DCB0160; UK Core.
- EU and UK GDPR, special category data.
- OWASP API Security Top 10 (2023).
