---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
metadata:
  fork:
    change: "Adds the Verify step: the change ships with Evidence from the repo's verification skill, not only green tests. Ends at a draft PR whose body the pr skill writes, after acting on code-review's findings, not at a commit: an Implementer told only to commit stopped with no PR (#14). Re-drives Verify after code-review fixes, so Evidence matches the pushed head (#20). A feature file's end state restates the ticket's acceptance criteria."
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

## Verify

Tests prove the code; Evidence proves the app. Look for the repo's verification skill at `.agents/skills/verify-*/` and read its `SKILL.md` and `features/README.md`.

With one present, drive the change the way a user would:

1. Set `VERIFY_RUN_ID` to the ticket's identifier (its number, or `local` without one) and follow the skill's Launch and Doctor sections.
2. Pick the feature files the change touches. When it touches none, pick the one closest to it. Drive each, capturing Evidence where the skill says, under `.evidence/<VERIFY_RUN_ID>/`.
3. When the change adds or alters a user-facing feature, update its feature file, or add one in the map's shape, in this same change. Its observable end state is the ticket's acceptance criteria, restated as what a user sees.
4. Run the skill's Cleanup.

Done when every driven feature's observed end state matches its feature file, and the Evidence files exist at their named location after Cleanup. A mismatch is a bug in the change or drift in the map: fix the one it is, and drive again.

Without a verification skill, note "No verification skill in this repo" for the PR body and let the test run stand as Evidence.

## Finish

1. Commit your work.
2. Call the Skill tool with "code-review" since `origin/<base>` (the branch the user named, else the default), with the ticket or the user's spec as the spec.
3. Fix its findings and commit, or say in the PR body why not. If a fix touched code, run Verify again, from Launch to Cleanup, for the feature files it affects, and commit what that run changes.
4. Push, write the body with the Skill tool and "pr", and open the PR as a draft against the base.

Done when the draft PR exists, its body has the Evidence section, and that Evidence was captured at the pushed head.
