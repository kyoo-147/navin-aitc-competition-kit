# Architecture

Status: DRAFT | LOCKED
Architecture Lavish artifact: `../artifacts/architecture.html`
Human approval evidence:

## System overview

<user -> browser UI -> full-stack server routes -> BTC Gateway modalities>

For a small multimodal web challenge, start from one full-stack web app. Add database, auth/account, CMS, microservice, Redis/queue, vector DB, or a product agent runtime only when the challenge or evidence requires it.

## Decision cards

| ID | Decision | Options considered | Chosen | Why | User approved |
| --- | --- | --- | --- | --- | --- |
| D-001 |  |  |  |  | no |

## Stack and deployment

- Full-stack app:
- Server routes:
- Database:
- AI/runtime:
- Deployment:
- External dependencies:

## Components and ownership

| Component | Responsibility | Owns state/data | Failure behavior |
| --- | --- | --- | --- |

## Data model and schema

<entities, relationships, constraints, migrations, retention>

## Frozen API contract

```text
method/path/event:
request:
response:
validation:
error states:
```

## Resource and media contract

- Live request cap / budget / RPM / TPM / max parallel:
- Required modalities:
- Structured generation schema:
- Media budget:
- Image generation contract:
- Cache/retry policy:
- Mandatory video start and poll plan:

## Authentication and security

- Identity:
- Authorization:
- Secrets boundary:
- Sensitive data:

## Failure paths

- Loading/timeout:
- Empty/not found:
- Recoverable failure:
- Blocking failure:
- Offline/degraded behavior:

## Rejected alternatives

- <alternative and reason>

## Open decisions

- None when status is LOCKED.
