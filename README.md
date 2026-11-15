# skills

The skills my agents and I run on. A frozen fork of
[mattpocock/skills](https://github.com/mattpocock/skills) plus two of
[pstack](https://github.com/cursor/plugins/tree/main/pstack)'s, two of
[ponytail](https://github.com/DietrichGebert/ponytail)'s, [improve](https://github.com/shadcn/improve) from shadcn and six of our own; `FORK.md` says what was taken from where and what was changed.

## Layout

- `skills/loop/`: the skills an agent runs on its own. `implement`, `research`
  and `quality-scan` are the entry points; `pr`, `tdd`, `code-review`, `codebase-design`,
  `ponytail-review` and `ponytail-audit` are reached from them.
- `skills/verify/`: `create-verification-skill` and
  `maintain-verification-skill`, which make and keep a Repo's `verify-<app>`
  skill, the thing `implement` drives. Its Evidence ends up in the PR body.
- `skills/hand/`: skills I invoke myself. `setup-matt-pocock-skills` is the
  one-time setup a Repo needs before `loop/` and `hand/` can read its tracker.

Every skill is one folder with a `SKILL.md`, and an `agents/openai.yaml` for
codex's invocation policy.

## Install

`scripts/link-skills.sh` symlinks every skill into `~/.claude/skills` and
`~/.agents/skills`, so a `git pull` keeps them current. Re-run it after adding,
removing or renaming a skill; it also drops the links to skills that moved or
went. Leave the `mattpocock-skills` plugin uninstalled: every skill would show
twice.

## Machine setup

`machine/opencode/commands/` holds OpenCode slash commands for the skills
OpenCode has no command for; `scripts/link-machine.sh` links them into place.
