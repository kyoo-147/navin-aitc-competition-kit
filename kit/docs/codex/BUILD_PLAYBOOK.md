# Michael's Build Playbook

This file defines how Michael wants agents to turn a problem or idea into a working product.

Core principle:

`Understand -> Search -> Design -> Build -> Verify -> Deploy -> Observe -> Improve`

## 1. Understand the Real Problem

Do not start with a framework, model, or architecture.

First understand:

- Who the user is
- What they are trying to accomplish
- The current workflow
- The pain point
- Inputs
- Desired outputs
- Decision points
- Failure points
- Constraints
- Risks

If the workflow is not understood, do not design the system yet.

## 2. Search Before Building

Before building anything substantial, check whether it already exists.

Search:

- Existing projects
- Existing repository code
- Open-source implementations
- GitHub
- Hugging Face
- Libraries
- SDKs
- Official APIs
- Papers
- Similar products
- Existing internal utilities

Prefer:

`reuse -> extend -> customize -> build new`

Do not rewrite a good system merely because building it from scratch seems more interesting.

## 3. Define the Smallest Complete Flow

Do not start with the entire platform.

Find the smallest vertical slice that can complete a real workflow.

A good prototype should have:

`real input -> real processing -> real result`

Do not use a fake implementation to create the impression that the product works when the core workflow does not run.

## 4. Architecture Follows the Problem

Add the following only when the problem actually requires them:

- Service
- Queue
- Database
- Agent
- Model
- Microservice
- Event system
- Abstraction
- Cloud infrastructure

Do not over-engineer from the beginning.

Prefer a simple architecture with clear boundaries so it can expand later.

## 5. Use Deterministic Software First

Do not use AI where deterministic software already solves the problem well.

Prefer the following for predictable parts:

- Rules
- Validation
- Classical algorithms
- Database queries
- State machines
- Traditional automation

Use AI for:

- Language
- Perception
- Ambiguity
- Reasoning
- Judgment
- Flexible interaction

A hybrid system is often better than an "AI everywhere" system.

## 6. Model Is a Replaceable Component

Avoid designing the entire product around a single model or provider when possible.

Separate:

`workflow logic`

from:

`model/inference backend`

so the model can be changed when:

- A better model appears
- Pricing changes
- Latency changes
- A provider has problems
- Local or edge execution becomes necessary
- Privacy requirements change

## 7. Build the Core Before Infrastructure

Prioritize proving the core workflow first.

Do not spend most of the early effort on the following before knowing whether the core product is useful:

- Perfect auth
- Complex permissions
- Distributed architecture
- Massive observability
- Premature scaling
- Generalized plugin systems

After the core flow is proven, harden the system deliberately.

## 8. Test With Real Data Early

Mock data is sufficient only for the earliest stage.

As early as possible, test with:

- Real user input
- Dirty data
- Missing data
- Long text
- Wrong formats
- Large files
- Edge cases
- Slow networks
- Provider failures
- Unexpected user behavior

Design for reality, not only the happy path.

## 9. Verification Is Part of the System

For important outputs, design the verification method from the beginning.

Possible mechanisms include:

- Schema validation
- Rules
- Tests
- Cross-checking
- Tool verification
- Confidence thresholds
- Human approval
- Retry
- Repair
- Fallback

Do not treat model output as correct merely because it sounds plausible.

## 10. Human Control Where It Matters

Autonomy should match the risk.

Actions with meaningful consequences should have:

- Permission boundaries
- Confirmation
- Review
- Undo
- Rollback
- Audit logs

Do not remove humans merely to make the product appear more autonomous.

## 11. UI Serves the Workflow

When building UI, read:

`~/.codex/TASTE_UI.md`

The UI should help users complete the task quickly and clearly.

Do not turn backend complexity into UI complexity.

Do not expose every capability merely because the system has it.

## 12. Ship a Working Vertical Slice

Prefer:

`one complete working flow`

over:

`many half-built features`

A vertical slice should run end to end and be testable like a real user flow.

## 13. Validate Before Expanding

After the prototype, ask:

- Do users actually use it?
- Is the workflow better?
- Does it reduce manual work?
- Is the output trustworthy?
- Is the latency acceptable?
- Is the cost reasonable?
- What is the main failure mode?

Expand functionality only when evidence shows that it is needed.

## 14. Deploy Early Enough to Learn

Local success is not production success.

Deploy early enough to discover:

- Environment issues
- Permission issues
- Network issues
- API limits
- Cost
- Latency
- Concurrency
- Real user behavior
- Operational failures

Do not wait for everything to be perfect before trying the system in a real environment.

## 15. Operate What You Build

After deployment, understand what the system is doing.

Depending on the importance of the system, monitor:

- Errors
- Logs
- Latency
- Cost
- Usage
- Success rate
- Model failures
- User corrections
- Queue or backlog
- Infrastructure health

Do not ask only:

> Does it run?

Also ask:

> Is it producing results that are correct and useful?

## 16. Fix Root Causes

When there is a bug:

`reproduce -> understand -> root cause -> fix -> verify`

Do not add workaround after workaround.

If the bug shows that the architecture or an assumption is wrong, fix that part.

## 17. Complexity Must Earn Its Place

Every new abstraction, dependency, or system must answer:

> What problem does this solve that a simpler approach does not solve?

If there is no clear answer, do not add it.

## 18. Improve Through Evidence

Iteration should be based on:

- User feedback
- Failure logs
- Usage patterns
- Evaluation
- Performance measurements
- Operational experience

Do not redesign the system merely because a new technology has appeared.

## Default Build Flow

Unless there is a specific reason to do otherwise:

`Understand problem`

↓

`Research existing solutions`

↓

`Map workflow`

↓

`Define smallest complete system`

↓

`Build vertical slice`

↓

`Test with real data`

↓

`Verify failures`

↓

`Deploy`

↓

`Observe`

↓

`Improve`

↓

`Scale only when needed`

## Final Build Check

Before considering a feature complete, ask:

- Does the core workflow run end to end?
- Could anything existing have been reused?
- Is there unnecessary complexity?
- Is there any fake or placeholder path?
- Has it been tested with real data?
- Are failures handled?
- Does the user know what the system is doing?
- Is rollback or recovery available when needed?
- Does it actually improve the user's workflow?

If not, the feature is not truly complete.
