# Final 30 Minutes

At approximately minute 90 of a 120-minute build window:

## Freeze

- [ ] Stop optional feature work.
- [ ] Record the known-good commit and deployment.
- [ ] Run independent spec and engineering review.
- [ ] Check live team spend and policy state.

## Repair order

1. P0 mandatory-flow, policy, deployment, or submission failure.
2. P1 scoring or reliability failure.
3. P2 only when low-risk time remains.

Do not perform broad refactors.

## Verify

- [ ] Build and required checks pass.
- [ ] Real end-to-end flow works with non-ideal input.
- [ ] Deployed version works if required.
- [ ] No secret is tracked or visible in artifacts.
- [ ] Branch, remote, commit, and dirty state are understood.
- [ ] Required AI Log events are submitted and visible through server readback.
- [ ] Final budget and reserve are checked.
- [ ] All final-round repository content is under `chung-khao/`, except organizer root infrastructure.

## Final five minutes

Freeze code, push the reviewed state, capture required evidence, and move to submission only.
