# skills

The skills the nico-agent loop and I run on. A frozen fork of
[mattpocock/skills](https://github.com/mattpocock/skills) plus two of
[pstack](https://github.com/cursor/plugins/tree/main/pstack)'s and four of our
own; `FORK.md` says what was taken from where and what was changed.

## Layout

- `skills/loop/`: what nico-agent's prompts call, and what those call in turn.
  `implement`, `research`, `verdict`, `faux-nico`, `quality-scan` and `morning`
  are the entry points; `pr`, `tdd`, `code-review` and `codebase-design` are
  reached from them.
- `skills/verify/`: `create-verification-skill` and
  `maintain-verification-skill`, which make and keep a Repo's `verify-<app>`
  skill, the thing `implement` and `verdict` drive.
- `skills/hand/`: skills I invoke myself. `setup-matt-pocock-skills` is the
  one-time setup a Repo needs before `loop/` and `hand/` can read its tracker.

Every skill is one folder with a `SKILL.md`, and an `agents/openai.yaml` for
codex's invocation policy.

## Install

`scripts/link-skills.sh` symlinks every skill into `~/.claude/skills` and
`~/.agents/skills`, so a `git pull` keeps them current. Re-run it after adding,
removing or renaming a skill; it also drops the links to skills that moved or
went. Leave the `mattpocock-skills` plugin uninstalled: every skill would show
twice. nico-agent's readiness check (`checks.rs`)
confirms each skill a prompt names is found for the Harness that runs it.

## Machine setup

`machine/` holds the Firstmate and no-mistakes config these skills run under,
and `scripts/link-machine.sh` links it into place. `machine/README.md` walks
through setting up a new machine and a new repo.
