# This fork

A frozen fork of [mattpocock/skills](https://github.com/mattpocock/skills),
owned and edited here. Upstream is read, never merged.

## Why frozen

Skills are prose. Merging prose is conflict after conflict, and upstream
renames things between versions. Once `implement` and `pr` carry our own
phases, every upstream merge would be resolved by hand anyway. So this repo
owns its skills, and upstream is a source of ideas.

- Frozen at upstream commit `49dd158` (2026-10-09), tag `frozen-2026-10-11`.
- Remote `upstream` points at Matt's repo for diffing only.

## Keeping up with upstream

Every two weeks a Research issue runs this and reports what changed and
which parts are worth porting by hand:

```sh
git fetch upstream
git diff frozen-2026-10-11..upstream/main -- skills/
```

After porting, move the `frozen-*` tag to the upstream commit reviewed.

## What was dropped

Everything of Matt's outside the skills kept here (docs pages, changesets,
plugin manifests, the release workflow, `misc/`, `in-progress/`, `ask-matt`)
is gone: this fork installs by symlink and publishes nothing, so a skill edit
is a skill edit. `README.md` has the layout.

An edited upstream skill records what changed and why under `metadata.fork`
in its frontmatter, so a diff against upstream stays readable.

## Edited upstream skills

| Skill | Change |
| --- | --- |
| `loop/implement` | A verification phase: run the repo's verification skill against the change and capture evidence before the PR. Ends at a draft PR written with `pr`, after acting on `code-review`'s findings, not at a commit. |
| `loop/pr` | A mandatory Evidence section in the PR body, with links to the evidence bucket. |

## Our skills (`skills/loop/`)

| Skill | Job |
| --- | --- |
| [`quality-scan`](skills/loop/quality-scan/SKILL.md) | Weekly per repo. Runs ponytail's audit and Matt's deepening scan and files issues, at most five of its own open at once: three pre-approved as `ready-for-agent` + `gardening`, two of the rest as `needs-triage`. |
| [`faux-nico`](skills/loop/faux-nico/SKILL.md) | Stands in for Nico when he is away. Answers an Asking Implementer from the repo's `PRODUCT.md`, the issue and its parent when they settle the question, otherwise ends so the question reaches him. |
| [`morning`](skills/loop/morning/SKILL.md) | Once a day. Reads what `nico-agent status --since` shows since the last one and writes `morning.md` in six sections: merge these in dependency order, answer these, fix these, what landed, what the scan filed, what faux-nico said. |
| [`verdict`](skills/loop/verdict/SKILL.md) | The Reviewer's. Re-runs the repo's verification skill at the PR's head, holds the PR's Evidence against it, holds the Implementer's Rulings on earlier Findings to account, and records pass or fail with `nico-agent verdict`. Never writes to GitHub. |

Planned, not yet written: the merge-conflict flow.

## Verification: Lauren Tan's, with credit

`skills/verify/` holds two skills from [pstack](https://github.com/cursor/plugins/tree/main/pstack)
by Lauren Tan ([poteto](https://github.com/poteto)), MIT, copied at
`cursor/plugins@9d76bca` on 2026-10-11 with her license beside them. Her
"trust first, then parallel" and verification-as-evidence are the ideas this
whole fork is built around. Read them in her words: the
[generator](https://github.com/cursor/plugins/blob/main/pstack/skills/create-verification-skill/SKILL.md)
and the [upkeep pass](https://github.com/cursor/plugins/blob/main/pstack/skills/maintain-verification-skill/SKILL.md).

| Skill | Hers, repointed |
| --- | --- |
| `verify/create-verification-skill` | Generates a repo's `verify-<app>` skill and feature map. Output lands in `.agents/skills/` so every Harness finds it; Evidence goes to `.evidence/<issue>/`, copied to the Bucket on Verdict. |
| `verify/maintain-verification-skill` | Keeps the feature map honest. Run weekly per Repo by the loop as a gardening issue. |

Pilot repo: `txpipe-shop/audit-notes`.
