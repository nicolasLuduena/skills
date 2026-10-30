---
name: manual-pr-review
description: Help a human review a pull request by hand: explain what it does in plain language, give a leaf-to-complex reading order, trace where each new input comes from, and surface concrete, verified findings. Use whenever someone says "review PR #123", "help me review this PR", "walk me through this diff", "ELI5 this PR", "what does this PR do", or wants a comprehension-first review they can act on. This is the human-in-the-loop companion to the standards/spec `code-review` skill: it is for understanding and judging a change, not for producing a compliance verdict.
---

# Manual PR review

Leave the reviewer able to explain the change and defend a decision about it. You are the guide, not the gate: the reviewer decides, you make the decision cheap.

## 1. Read the PR before you opine

Fetch, in order: the PR (title, body, changed files, base/head, additions/deletions), the full diff, and the issue(s) it closes plus any ADR or design note it cites. Read the whole diff before writing a single finding.

The PR body often already states the intent, the risks the author knows about, and the follow-ups. Quote it rather than inventing a frame: which PR is the base, and does the diff carry only this PR's commits or an ancestor's too.

Ground every "why" in the issue/ADR, never in a guess. If the PR closes #78 and an ADR exists, cite them.

## 2. Lead with an ELI5

The reviewer needs a model before details:
- **one sentence**: what changes, in plain words;
- **the problem it solves**: the failure or gap, cited to the issue;
- **the mechanism**: the smallest accurate account of how it works.

## 3. Show the process before and after

A file-by-file diff hides the shape of the change: what used to happen end to
end, and what happens now. Walk the flow the diff touches twice, once before
the change and once after, in the same plain vocabulary as the ELI5. Name the
entry point, the steps in order, and where the new code takes over. Cover only
the paths the diff changes, not the whole system. Two short paragraphs or a
two-row before/after table both work. If the flow did not change, say that
instead of inventing a difference.

## 4. Give a reading order, leaf → complex

Order files by dependency: types and leaves first, load-bearing logic last, so each file is understood on already-read ground. A table works: file, why here, and what to ask while reading it. The per-stop questions are the point ("is this injective?", "does the hash commit to what is enforced?", "any behaviour drift?").

## 5. Trace provenance of new inputs

For every new field, parameter, or config, say who authors it, where it comes from, and whether it is trustworthy. Distinguish values a witness/attestor signed from values the client merely asserts. "Where does this actually come from?" is the most common real question.

## 6. Findings: concrete, verified, cited

Reproduce before asserting. If you claim `Array(1)` collides with `[]`, run it and paste the output. A finding without a demo is a guess.

Hunt specifically for:
- **Doc drift**: a comment that no longer matches the code (a schema that still says "no length check" after gaining one).
- **Name collisions**: the same identifier across entry points or subpaths meaning different things.
- **Scope creep**: unrelated work smuggled into the PR; recommend it move to its own.
- **Asymmetry**: one object under two rules (two fields length-checked, two not).
- **Unchecked fields**: signed but never verified; say what it buys and who must check it.
- **Disclosure / privacy**: a circuit `disclose` or public field leaking more than intended; say whether that is accepted.
- **Removed guards**: a deleted assert or validation; say what catches the case now.
- **Frozen vectors moving**: a changed hash, canonical form, or wire layout; name what else depends on the old one.

For each finding, say whether it is **live** or **latent**, and whether it is a **bug**, a **doc fix**, or a **judgement call** for the author. Cite `file:line`.

## 7. Say what's in and what's out

List the deferred work the PR names, plus anything you notice it does not cover. Reviewers need the boundary, not just the content.

## 8. Optional: a visual map

When the key file is dense (a hashing routine, a state machine, a wire layout), a standalone HTML map (purpose, pipeline, line ruler, review radar) compresses it better than prose. Build it only when it earns the effort; skip it for a small diff.

## 9. Answer questions the way they're asked

A yes/no question gets a yes or no first, then the reasoning. If the reviewer agrees with a finding, verify it before amplifying. If you disagree, say so and show why.

## Output shape

Default to this order unless the reviewer asks otherwise:

1. **ELI5**: sentence, problem, mechanism.
2. **The process before and after**: the touched flow as it ran before and as it runs now, in the ELI5's vocabulary. Two short paragraphs or a two-row table.
3. **The changes**: a short table: layer → before/after.
4. **Review order**: the leaf→complex table with per-stop questions.
5. **Findings**: numbered, each with a verdict (live/latent, bug/doc/judgement) and `file:line`.
6. **In / out**: deliberate scope and known follow-ups.
7. **Offer**: the visual map, or acting on a finding, when either helps.

## Relationship to `code-review`

`code-review` produces a Standards/Spec compliance verdict via parallel sub-agents against a fixed point. This skill produces understanding and human-facing findings against a PR. They compose: run this to learn the change and gather findings, run that when a formal two-axis verdict is wanted. If the reviewer only wants the verdict, defer to `code-review`; if they want to *understand and judge*, stay here.

## When asked to act, not just review

If the reviewer asks you to fix a finding: put it in the PR that owns the change (the one that introduced the code), not a drive-by in an unrelated one, and reply on the review thread with the commit. Watch scope: a review finding that belongs in a later PR should be filed, not smuggled.
