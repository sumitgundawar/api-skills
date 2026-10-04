# E-learning API checklist

## Standards: use them where they fit

| Need | Standard | Notes |
|------|----------|-------|
| Launch an external tool from the platform with single sign-on | LTI 1.3 (1EdTech) | Built on OAuth 2 and OpenID Connect with signed JWTs. Replaces LTI 1.1, whose signing method is deprecated. |
| Tool picks content, sends grades, reads the class list | LTI Advantage: Deep Linking, Assignment and Grade Services, Names and Role Provisioning Services | Each service has its own scopes. Ask only for what you use. |
| Exchange rosters, courses and grades with a student information system | OneRoster 1.2 (1EdTech) | REST and CSV bindings. |
| Portable questions and tests | QTI 3.0 (1EdTech) | |
| Record learning activity anywhere | xAPI 2.0 (IEEE 9274.1.1-2023) | Statements of actor, verb and object, stored in a Learning Record Store. |
| Launch and track packaged content with xAPI | cmi5 | The modern successor to SCORM packaging rules. |
| Learning analytics events | Caliper Analytics 1.2 (1EdTech) | |
| Verifiable certificates and badges | Open Badges 3.0, Comprehensive Learner Record 2.0 (1EdTech) | Aligned with W3C Verifiable Credentials. |
| Legacy packaged content | SCORM 1.2 or 2004 | Still everywhere. Support it at the edges, do not design around it. |

Check the current version on the 1EdTech and IEEE sites before you build. The versions above were current when this was written in October 2026.

## Identity, roles and tenancy

- [ ] Every request is scoped to an institution (tenant) taken from the credential.
- [ ] Roles are per context: a person can be a teacher in one course and a learner in another.
- [ ] Object-level checks exist on submissions, grades, feedback and messages (OWASP API1).
- [ ] Function-level checks separate learner, teacher and administrator operations (OWASP API5).
- [ ] Field-level checks hide other learners' names, scores and feedback (OWASP API3).
- [ ] Guardians and observers get read access only to the learners they are linked to.
- [ ] Impersonation by support staff is logged and visible.

## Rosters and enrolment

- [ ] One system is the authority for enrolment, and the API says which.
- [ ] Sync is incremental (changes since a point), cursor paginated and resumable.
- [ ] Running the same sync twice changes nothing.
- [ ] Removal from a course removes access promptly, and keeps the academic record.
- [ ] Bulk enrolment is an asynchronous job with a per-row result.

## Launches (LTI 1.3)

- [ ] Messages are signed and the signature, issuer, audience, nonce and expiry are all validated.
- [ ] The OpenID Connect `state` value is checked on the launch. Launches inside an iframe are tested with third-party cookies blocked, which is the most common cause of LTI 1.3 launch failures in production. Use the platform storage mechanism defined by 1EdTech where cookies are unavailable.
- [ ] Keys are published as a JWKS and can be rotated.
- [ ] Each tenant has its own deployment identifier and client registration.
- [ ] The launch sends the least personal data. Name and email are optional claims.
- [ ] Deep links are validated before they are stored.
- [ ] Service tokens (grades, names and roles) are short-lived and scoped.

## Submissions and assessments

- [ ] Submitting is idempotent with a key. A retry at the deadline does not create two attempts or lose the first.
- [ ] The server records the submission time. The client's clock is not trusted.
- [ ] The learner gets a receipt identifier.
- [ ] Large files upload directly to storage with a pre-signed URL and can resume.
- [ ] Attempt limits, time limits and accommodations (extra time) are enforced on the server.
- [ ] Autosave is frequent, cheap and safe to repeat.
- [ ] Answers and marking keys are never sent to the client before they should be.

## Grades

- [ ] A score write is safe to repeat and carries a timestamp. An older score does not overwrite a newer one.
- [ ] Grade passback to another system is queued, retried with backoff, and reconciled.
- [ ] Every grade change is audited: who, when, old value, new value, reason.
- [ ] Released and unreleased grades are distinct states. Learners see only released ones.
- [ ] Updates use a version so two markers cannot overwrite each other silently.

## Learning records

- [ ] Statements are accepted in batches and processed asynchronously.
- [ ] Duplicates are handled by statement identifier as xAPI requires: an identical statement with the same identifier changes nothing, and a different statement with the same identifier is a conflict (409).
- [ ] The record store is not on the critical path of a learner's submission.
- [ ] Analytics data is pseudonymised where the purpose allows.

## Load

- [ ] Start times and deadlines are planned for. Admission to a timed assessment is paced.
- [ ] Submission and autosave have reserved capacity. Analytics, notifications and reports are shed first.
- [ ] Limits are cost-based. Canvas LMS, for example, charges each request its CPU time plus database time against a leaking bucket and returns the cost and the remainder in headers.
- [ ] Integrations that poll are given webhooks or change feeds instead.

## Privacy and retention

- [ ] The platform knows which users are children, and which rules apply in each market.
- [ ] Data shared with third-party tools is listed per tool and can be reviewed by the institution.
- [ ] Export and erasure requests can be met per learner, including data held by integrated tools.
- [ ] Retention periods are defined per record type. Academic records outlive accounts.
- [ ] Logs do not contain submissions, answers or special category data.
- [ ] AI features that process learner work are disclosed, can be turned off by the institution, and do not train models on learner data without agreement.

## Agents

- [ ] Decide whether AI agents may act for a learner at all. For assessed work the answer is usually no, and the API should make that enforceable: authenticated sessions, attested clients for high-stakes assessments, quotas sized for a person.
- [ ] Agents acting for teachers or administrators (marking support, roster checks) get scoped, short-lived tokens and an audit trail.
- [ ] Course catalogues and public course information are fine to expose in machine-readable form.

## Also check

- [ ] On every LTI 1.3 launch, the issuer, the client identifier (the token's audience) and the deployment identifier are all checked against one stored registration. A token that is valid for one institution is refused for another.
- [ ] Rostering covers the routes institutions really use, not only the standard. In United States schools that is often Clever or ClassLink. In United Kingdom schools it is often an aggregator in front of the school's management information system.
- [ ] Remote proctoring data (video, audio, screen, biometric templates) is treated as the most sensitive data in the system: explicit lawful basis, short retention, restricted access, and an alternative for learners who cannot use it.
- [ ] AI that scores work, steers a learner's path or monitors an exam is identified. Under the EU AI Act, systems that evaluate learning outcomes or detect prohibited behaviour during tests are listed as high risk, and emotion recognition in education institutions is prohibited except for medical or safety reasons. Check the current application dates and take advice.

## Sources

- 1EdTech specifications: LTI 1.3 and LTI Advantage, OneRoster 1.2, QTI 3.0, Caliper 1.2, Open Badges 3.0, CLR 2.0.
- IEEE 9274.1.1-2023 (xAPI 2.0). cmi5 specification.
- Instructure developer docs, Canvas API throttling.
- OWASP API Security Top 10 (2023).
- FERPA and COPPA (United States); UK Age Appropriate Design Code; GDPR.
