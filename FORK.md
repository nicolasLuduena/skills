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

## Layout

- `skills/engineering/`, `skills/productivity/`, `skills/misc/`: Matt's
  skills. Most are untouched. An edited one starts with a `> Fork:` note
  saying what changed and why, so a diff against upstream stays readable.
- `skills/nico/`: ours. Skills Matt does not have, written for the
  nico-agent loop.

### Edited upstream skills

| Skill | Change |
| --- | --- |
| `engineering/implement` | A verification phase: run the repo's verification skill against the change and capture evidence before the PR. |
| `engineering/pr` | A mandatory Evidence section in the PR body, with links to the evidence bucket. |

### Our skills (`skills/nico/`)

| Skill | Job |
| --- | --- |
| `faux-nico` | Stands in for Nico when he is away. Answers an Implementer's question from the repo's `PRODUCT.md` when the docs settle it, otherwise leaves it for him. When the loop runs dry, dispatches existing gardening issues. |
| `quality-scan` | Weekly per repo. Runs ponytail's bloat audit and Matt's deepening scan and files issues: pre-approved categories as `ready-for-agent` + `gardening`, the rest as `needs-triage`. |
| `morning` | Once a day. Reads the night's action log and PRs and writes `morning.md`: merge these in this order, these need an answer, these failed, this gardening landed, these ideas were filed. |

Planned, not yet written: the merge-conflict flow.

## Verification

Not ours. pstack's `create-verification-skill` and
`maintain-verification-skill` (in `cursor/plugins`) are to be read first and
then adopted, tweaked, or replaced. Decision pending. Pilot repo:
`txpipe-shop/audit-notes`.

## Installing

Install from this repo with the `skills` CLI, one skill at a time, so
`skills-lock.json` in each project points here:

```sh
npx skills add nicolasLuduena/skills --skill implement
```

Do not also install the `mattpocock-skills` plugin: every skill would show
twice.
