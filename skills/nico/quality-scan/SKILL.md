---
name: quality-scan
description: "Audit a Repo with ponytail-audit and a deepening scan and file the top findings as issues, at most five open at once, without editing code."
disable-model-invocation: true
---

# Quality scan

Audit the Repo named by the argument (`owner/name`) and file its top findings as issues on its **Source**, the issue tracker it works from. You run in a checkout of that Repo. The checkout ends exactly as it started: you read and run read-only commands, and your only writes are issues and labels on the Source.

## 1. Read the rules and count the free slots

- `PRODUCT.md`, its `## Gardening` section: the **pre-approved** categories, one per item. No section, or no file, means nothing is pre-approved.
- `AGENTS.md` or `CLAUDE.md`: the Repo's Source (GitHub Issues through `gh`, or a Linear team) and how agents write to it, such as a bot wrapper used in place of `gh` or a fingerprint line every body must end with. Every read and write below goes to that Source by those rules.
- `GLOSSARY.md`, when present: its words go in every title and body you write.
- The Source's open issues: every title, and which of them carry the line `Filed by quality-scan.` in their body. On GitHub, `gh issue list --repo <owner/name> --state open --limit 1000 --json number,title`, then the same with `--search '"Filed by quality-scan" in:body' --json number,labels`.
- `git rev-parse HEAD` and `git status --porcelain`: the checkout's starting state.

The scan keeps at most five of its issues open, in two pools of **slots**:

- **Gardening**: 3 slots, minus the open quality-scan issues labelled `gardening`.
- **Triage**: 2 slots, minus the open quality-scan issues labelled `needs-triage`.

A slot frees when its issue closes, or when the user triages it out of `needs-triage`. With no free slot in either pool, go straight to step 5: the run files nothing, whatever a scan would find.

Done when you hold the pre-approved list (maybe empty), the write rules, the open titles, the free slots per pool, and the starting state.

## 2. Scan

Two passes over the whole Repo, both read-only.

1. **Audit.** Call the Skill tool with "ponytail-audit". Keep its numbered findings in their groups: Must fix, Should fix, Nice to have.
2. **Deepening scan.** Call the Skill tool with "codebase-design" and use its vocabulary (module, interface, depth, seam, adapter, leverage, locality). Read any ADRs, which record decisions not to re-litigate. Walk back a good stretch of `git log --oneline` to find the hot spots, the areas that keep changing, and look there first. Then walk the codebase organically, in a sub-agent when you can start one, noting friction:
   - understanding one concept means bouncing between many small modules;
   - a **shallow** module, its interface nearly as complex as its implementation;
   - pure functions extracted for testability while the bugs hide in how they are called (no locality);
   - tightly coupled modules leaking across their seams;
   - code that is untested, or hard to test through its interface.

   Apply the deletion test to each suspect: deleting it would concentrate complexity, or only move it? Keep each candidate as a note of its files, the friction and its grade: `Strong`, `Worth exploring` or `Speculative`. The interface is designed later, by whoever takes the issue.

Done when the audit has given its report, every hot spot has been walked, and every candidate is graded.

## 3. Rank and choose

Merge both lists into one ranking, each group keeping its own order: the audit's Must fix, the scan's Strong, the audit's Should fix, the scan's Worth exploring, the audit's Nice to have. Drop Speculative. Two entries naming the same change to the same code are one finding, at the higher rank.

Give each finding:

- **Title**: what to do and where, in the Repo's words, e.g. `Delete the unused retry option (src/config.rs)`.
- **Pool**: Gardening when the finding falls squarely in one category of the `## Gardening` list, else Triage. A finding in doubt goes to Triage.

Then, pool by pool, walk the ranking from the top. **Skip** a finding when an open issue's title names the same change to the same code, whatever its wording; otherwise mark it file, until the pool's free slots are used.

Done when every free slot holds a finding marked file, or the ranking has no finding left for its pool.

## 4. File

File each finding marked file, in rank order, with this body. The `Filed by quality-scan.` line is how the next run counts its slots: keep it verbatim.

```markdown
## What to build

<What to do and why: the problem and the concrete case the scan found, in two to four sentences.>

Files: `<path>`, `<path>`

Category: <the pre-approved category, or "not pre-approved">.

Filed by quality-scan.

## Acceptance criteria

- [ ] <the observable end state, e.g. "the option is gone and nothing references it">
- [ ] Tests and lint pass

## Blocked by

None (can start immediately)
```

Label a Gardening finding `gardening` and `ready-for-agent`, a Triage finding `needs-triage`. Create a label the Source lacks before its first use.

Done when every finding marked file has its issue with its labels.

## 5. Report

Check the checkout: `git rev-parse HEAD` and `git status --porcelain` print the starting state. When they differ, the run broke its contract: name every changed path in the report.

End with one line per issue filed, in rank order: `<issue url> <title> [<labels>]`. With nothing filed, the one line is `Nothing filed: ` and why (no free slot, every finding matched an open issue, or the scan found nothing).
