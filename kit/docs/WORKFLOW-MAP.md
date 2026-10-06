# Captain and Repository Workflow

## 1. Session gate

```text
New request
→ Captain asks OFFICIAL or DRILL
→ OFFICIAL: verify origin and work only in official repo/chung-khao
→ DRILL: use preparation workspace and label evidence as drill
```

No research, edits, browser control, or worker dispatch begins before the mode answer.

## 2. Decision workflow

```text
Challenge / idea
→ Spec Broker structures requirements without choosing architecture
→ requirements scout || technical scout || UX scout
→ Human Brief with 1-3 decision-critical questions
→ Architecture Lavish || interactive UX Flow Lavish
→ user annotates and approves
→ HUMAN LOCK
→ compile five source-of-truth documents
→ hash-lock documents and artifacts
→ implementation-gate.ps1
```

Implementation is allowed only when the gate prints `IMPLEMENTATION ALLOWED`.

## 3. Repository layout in OFFICIAL mode

```text
official repository root/
├─ organizer hooks and config        # preserve at root
└─ chung-khao/
   ├─ docs/
   │  ├─ PROJECT.md
   │  ├─ ARCHITECTURE.md
   │  ├─ UX_FLOW.md
   │  ├─ DECISIONS.md
   │  ├─ TASKS.md
   │  └─ PROJECT_LOCK.json
   ├─ artifacts/
   │  ├─ architecture.html
   │  └─ ux-flow.html
   ├─ frontend/                      # actual layout follows locked architecture
   ├─ backend/                       # actual layout follows locked architecture
   └─ evidence/
```

The exact application folders are chosen by the user through Architecture Lavish. Workers cannot invent or replace them.

## 4. Git and worker flow

```text
verified official base SHA
├─ Orca worktree A / backend branch
│  └─ backend + DB + API + AI/runtime + backend checks → commit A
├─ Orca worktree B / frontend branch
│  └─ screens + interactions + states + frontend checks → commit B
└─ optional read-only reviewer

Captain verifies A and B independently
→ Captain integrates commit A and commit B
→ resolve only contract-conformant conflicts
→ remove critical-path mocks/adapters
→ real FE/BE E2E
→ fixed-point Spec review
→ fixed-point Standards/Engineering review
→ fixed-point Competition Provenance review
→ leader review
→ commit/push/submit only when authorized
```

Frontend and backend do not integrate while either lane is still building. A frontend contract adapter is permitted only for lane testing and is not proof of real integration.

## 5. Browser workflow

```text
Need browser evidence?
→ static fetch is enough: use fetch/curl
→ interaction is required: start isolated automation browser
→ run one bounded flow
→ capture scrubbed evidence
→ stop isolated browser

Need the user's signed-in Chrome?
→ explain why isolated browser is insufficient
→ request explicit permission for this session
→ one attach attempt only
→ failure means stop; never retry or restart Chrome
```

`chrome-devtools-axi` is installed but remains on-demand. Auto-connect, browser URL attachment, and SessionStart hooks stay disabled.

## 6. Acceptance evidence

The Captain reports:

- mode and repository identity;
- Human Lock and unchanged project hashes;
- writer branches, commits, ownership, and verification;
- integrated SHA and clean status;
- targeted tests, build, real runtime, and FE/BE E2E;
- exact BTC provider and AI Log evidence in official mode;
- spend state, deployment proof, and submission receipt where required;
- every missing item as `UNVERIFIED` or `BLOCKED`.
