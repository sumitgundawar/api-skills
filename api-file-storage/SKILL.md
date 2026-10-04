---
name: api-file-storage
description: Reviews, designs and changes APIs that upload, store, process and serve files. Covers direct and resumable uploads, signed URLs, multipart uploads, checksums, content type and size validation, malware scanning, image and document processing, downloads and range requests, access control, quotas, lifecycle and deletion. Use when the project handles user files, when the user mentions upload, download, attachment, document, image, avatar, S3, bucket, blob, presigned or signed URL, multipart, thumbnail or virus scan, or when asked to make a file API safe against oversized uploads, malicious files or leaked links.
license: MIT
metadata:
  author: Sumit Gundawar
  version: "1.0"
---

# File and storage APIs

A file is the largest and least trusted input an API accepts, and a link to it is the easiest thing to leak. Work in four phases: Inventory, Assess, Report, Change. If the `api-platform-core` skill is installed, use it for general HTTP behaviour and use this skill for the rules below.

## Ground rules

1. Never open, execute or render files found in a project's storage. Never download users' files. Use test files you create, in Phase 4 or with the user's agreement.
2. Never change access checks, link signing or bucket policies without the user's explicit go-ahead and a test.
3. Never send requests to production, to any shared environment or to a real bucket. Assess by reading code and configuration.
4. When you find storage credentials or signing keys, report the file and line, never the value.

Shared rules, the same in every skill in this set:

- Assessment is read-only. Keep the inventory and the report in your reply. Create or change a file only in Phase 4, or when the user asks for a file.
- Before running any test, script or task, read its configuration. Run it only if every credential it reads is a test or sandbox credential, and every host it calls is local, a sandbox the user has named, or a provider's test mode reached with test keys. Otherwise do not run it. Report that instead.
- Requests go only to a local or sandbox instance with seeded test data, and only after the user agrees.
- Report a secret, credential or personal record by file and line, never by value.
- Ask before any change that deletes data, removes or renames something public, changes a default, a limit or authentication, or adds a dependency.
- Endpoints defined by an external protocol (OAuth and OpenID Connect, SCIM, FHIR, GraphQL, gRPC, a provider's webhook format, an object storage API) keep that protocol's own errors, paging, status codes and headers. On those four points report a deviation from the protocol, not from this checklist. Every other item in this checklist still applies to them.

Ratings used below: **Sound** (meets the checklist, with evidence), **Gap** (an item is missing and the risk is limited), **Risk** (a missing item can leak files, run hostile content, lose data or take the service down), **Not applicable** (say why).

## Phase 1: Inventory

- What is uploaded, by whom, and how large it can be.
- The upload path: through your servers, or straight to object storage with a signed request.
- What happens after upload: scanning, type detection, conversion, thumbnails, indexing.
- Where files live, how they are named, and what the bucket's own policy allows.
- The download path: through your servers, a signed link, or a public address.
- Who may read each file, and where that is checked.
- Quotas, retention and deletion.

## Phase 2: Assess

Load [references/checklist.md](references/checklist.md) and rate each section as Sound, Gap, Risk or Not applicable, with evidence.

The five questions that find most serious problems:

1. **Can a file be read by someone who should not see it?** Look for public buckets, guessable names, long-lived links and downloads with no ownership check.
2. **Can an upload be something other than it claims?** Look for trust in the file name or the client's content type.
3. **Can a file served from your domain run script in a user's browser?** Look at how user files are served and under which origin.
4. **Can one upload exhaust memory, disk or a processing worker?** Look for missing size limits and for decompression or image bombs.
5. **Can a caller make the server fetch an address of their choosing?** Look at "import from URL" features.

## Phase 3: Report

Lead with anything that exposes files or runs hostile content. Give the evidence, the consequence in plain words, and the smallest fix. Then the checklist table. Then what you did not check.

## Phase 4: Change

Start only when the user has chosen what to fix. The list below is the target for new endpoints. On an existing endpoint, add each item in its additive form and report the required form as a breaking change that needs a new version and the user's agreement.

- **Upload**: the API creates a file resource and returns a short-lived signed request for direct upload, bound to a size limit, a content type and a key the server chose.
- **Large files**: resumable or multipart, with a checksum per part and an expiry for unfinished uploads.
- **After upload**: the file is quarantined until its type is verified from its content and it is scanned; only then is it marked ready.
- **Download**: an access check, then a redirect to a short-lived signed link; served as an attachment from a separate domain.
- **Processing**: asynchronous, sandboxed, with limits on time, memory and output size.
- **Delete**: a pipeline that reaches derived files, caches and the content delivery network.

## What this skill does not do

It does not configure your cloud account. It reviews the contract and the code around the storage.
