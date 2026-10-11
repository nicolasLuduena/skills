---
name: quality-scan
description: "Audit a Repo for bloat and shallow modules and file the top five findings as issues, without editing code."
disable-model-invocation: true
---

# Quality scan

Audit the Repo named by the argument (`owner/name`) and file its top findings as issues. You run in a checkout of that Repo. The checkout ends exactly as it started: you read and run read-only commands, and your only writes are issues and labels on the Repo's tracker.

## 1. Read the rules

- `PRODUCT.md`, its `## Gardening` section: the **pre-approved** categories, one per item. No section, or no file, means nothing is pre-approved.
- `AGENTS.md` or `CLAUDE.md`: the Repo's tracker (GitHub Issues through `gh`, or a Linear team) and how agents write to it, such as a bot wrapper used in place of `gh` or a fingerprint line every body must end with. Every write below follows these rules.
- `GLOSSARY.md`, when present: its words go in every title and body you write.
- The title of every open issue on the tracker (`gh issue list --repo <owner/name> --state open --limit 1000 --json number,title`).
- `git rev-parse HEAD` and `git status --porcelain`, kept for step 5.

Done when you hold the pre-approved list (maybe empty), the write rules, the open titles, and the checkout's starting state.

## 2. Scan

Two passes over the whole Repo, both read-only.

1. **Audit.** Call the Skill tool with "ponytail-audit". Keep its numbered findings in their groups: Must fix, Should fix, Nice to have.
2. **Deepening scan.** Call the Skill tool with "codebase-design" and use its vocabulary (module, interface, depth, seam, adapter, leverage, locality). Read any ADRs, which record decisions not to re-litigate. Walk back a good stretch of `git log --oneline` to find the hot spots, the areas that keep changing, and look there first. Then walk the codebase organically, in a sub-agent when you can start one, noting friction:
   - understanding one concept means bouncing between many small modules;
   - a **shallow** module, its interface nearly as complex as its implementation;
   - pure functions extracted for testability while the bugs hide in how they are called (no locality);
   - tightly coupled modules leaking across their seams;
   - code that is untested, or hard to test through its interface.

   Apply the deletion test to each suspect: deleting it would concentrate complexity, or only move it? Grade each candidate `Strong`, `Worth exploring` or `Speculative`. Write no report file and propose no interface.

Done when both passes have given their lists.

## 3. Pick five

Merge both lists into one ranking, each group keeping its own order: the audit's Must fix, the scan's Strong, the audit's Should fix, the scan's Worth exploring, the audit's Nice to have. Drop Speculative. Two entries naming the same change to the same code are one finding, at the higher rank.

Take the first five. They are the run's whole budget: each is skipped or filed, and nothing past the fifth is looked at, so a re-run on an unchanged Repo files nothing. For each of the five, decide:

- **Title**: what to do and where, in the Repo's words, e.g. `Delete the unused retry option (src/config.rs)`.
- **Skip** when an open issue's title names the same change to the same code, whatever its wording.
- **Category**: pre-approved when the finding falls squarely in one category of the `## Gardening` list. A finding in doubt is not pre-approved.

Done when each of the five is marked skip, or file with its title and category.

## 4. File

File each finding marked file, in rank order, with this body:

```markdown
## What to build

<What to do and why: the problem and the concrete case the scan found, in two to four sentences.>

Files: `<path>`, `<path>`

Category: <the pre-approved category, or "not pre-approved">. Filed by quality-scan.

## Acceptance criteria

- [ ] <the observable end state, e.g. "the option is gone and nothing references it">
- [ ] Tests and lint pass

## Blocked by

None (can start immediately)
```

Label it `gardening` and `ready-for-agent` when its category is pre-approved, else `needs-triage`. Create a label the tracker lacks before its first use. On Linear, the same title, body and labels go through the team the rules name.

Done when every finding marked file has its issue with its labels.

## 5. Report

Check the checkout: `git rev-parse HEAD` and `git status --porcelain` print what they printed in step 1. Remove anything the run left until they do.

End with one line per issue filed, in rank order: `<issue url> <title> [<labels>]`. With nothing filed, the one line is `Nothing filed: ` and why (every finding matched an open issue, or the scan found nothing).
