---
name: api-elearning
description: Reviews, designs and changes APIs for learning platforms. Covers courses, enrolments, rosters, content launch, assessments, grades and grade passback, learning records, credentials, exam-period load, and learner privacy including children's data. Knows the interoperability standards LTI 1.3 and LTI Advantage, OneRoster, QTI, xAPI, cmi5, Caliper and Open Badges. Use when the project is an LMS, a learning tool, a course marketplace or an assessment system, or when the user mentions enrolment, roster, gradebook, LTI, SCORM, xAPI, Canvas, Moodle or student data.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# E-learning APIs

Learning platforms hold records that follow people for years, many of their users are children, and their busiest hour is an exam deadline. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the domain rules below.

## Ground rules

1. A grade is an education record with legal protections in many jurisdictions. Never change grade, attempt or completion logic without the user's explicit go-ahead and a test.
2. Treat every learner as possibly a minor until the project says otherwise. Collect and return the least personal data that the task needs.
3. Prefer the established interoperability standards over a custom integration. Institutions will ask for them by name.
4. Do not weaken an assessment's integrity controls (time limits, attempt limits, proctoring hooks) as a side effect of another change.
5. Never send requests to a deployed environment. These systems hold children's records. Assess by reading code and tests. Make requests only against a local or sandbox instance with seeded test accounts, and only after the user agrees.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can lose a submission, corrupt a grade, leak a learner's data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

Map the domain and who is the authority for each part:

- Organisations, terms, courses, sections.
- People and roles: learner, teacher, guardian, administrator.
- Enrolments: who is in what, in which role, and where that list comes from (the student information system is usually the authority, not the LMS).
- Content and launches: how a learner gets from the platform into a tool or a content package.
- Assessments: items, attempts, submissions, timing.
- Grades: line items, scores, results, and where they are sent.
- Learning records and analytics events.
- Credentials: certificates and badges.

Note which standards the project already speaks, and which version.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can a learner read or change another learner's work or grade?** Read the submission and grade handlers and check that each compares the record's owner and the caller's role with the request. A learner must not reach teacher operations. If there is no test for it, record that as a finding and propose the test in the report. Write it only in Phase 4, after the user agrees, on a branch.
2. **Can a submission be lost or duplicated at the deadline?** Follow a submission through a timeout and a retry. Look for an idempotency key and a server-side timestamp.
3. **Is the roster in step with its authority?** Look at how enrolment changes arrive, and what happens to access when a learner is removed.
4. **What personal data leaves the platform on a tool launch?** Read the launch claims. Names and emails should be sent only when the tool needs them.
5. **What happens in exam week?** Look for limits, queues and a plan for a thundering herd at the start time and the deadline.

## Phase 3: Report

Lead with anything that exposes a learner's data, can lose a submission, or can corrupt a grade. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form (accept the key, add a cursor parameter beside the offset) and report the required form as a breaking change that needs a new version and the user's agreement.

Default design for the endpoints that matter:

- **Submit work**: accepts an idempotency key, and requires it on new endpoints or in a new version; the server records the time; the response confirms receipt with an identifier the learner can keep; late rules are applied on the server.
- **Record a score**: one operation per line item and learner, safe to repeat, with a timestamp so an older score cannot overwrite a newer one.
- **Roster sync**: incremental, cursor paginated, resumable, and tolerant of being run twice.
- **Tool launch**: LTI 1.3 with signed messages; the least personal data; one deployment identifier per tenant.
- **Learning records**: accepted asynchronously in batches, deduplicated on a statement identifier.
- **Assessment start**: admit at a controlled rate; pre-load content before the start time; never let analytics or notifications compete with submissions for capacity.

## What this skill does not do

It does not give legal advice on FERPA, COPPA, the UK Children's Code or GDPR. It tells you where a privacy review is needed.
