# Machine setup

The config that turns a machine into mine: Firstmate runs the crew in Herdr,
workers implement with these skills on OpenCode, and no-mistakes reviews,
tests and opens each PR. `scripts/link-machine.sh` symlinks every file here
into place, so an edit a tool makes lands in this repo, ready to commit.

## What's here

- `firstmate/config/backend`: the session backend, `herdr`.
- `firstmate/config/crew-dispatch.json`: which harness and model a worker
  gets. The default is OpenCode with `opencode-go/deepseek-v4.1-flash`; a rule
  per project goes here.
- `firstmate/data/captain.md`: my standing instructions to the first mate.
  `/stow` adds to it.
- `no-mistakes/config.yaml`: the global no-mistakes config. Every pipeline
  step runs on OpenCode with `opencode-go/deepseek-v4.1-flash`.
- `no-mistakes/repo.no-mistakes.yaml` and `no-mistakes/pull_request_template.md`:
  the starting files for each repo the crew works on. They are copied, not
  linked: each repo commits its own.

## A new machine

1. Install and sign in: `gh auth login`, Claude Code, OpenCode (signed in to
   OpenCode Go) and Herdr.
2. Install no-mistakes on the prerelease channel. Stable can't drive
   OpenCode 2:

   ```sh
   curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh
   no-mistakes update --beta
   ```

3. Clone this repo and Firstmate, then link:

   ```sh
   git clone https://github.com/kunchenguid/firstmate ~/firstmate
   scripts/link-skills.sh
   scripts/link-machine.sh
   no-mistakes daemon restart
   ```

4. Launch the first mate in a terminal you keep open, and let it check its
   tools (it asks before installing any):

   ```sh
   cd ~/firstmate && claude
   ```

## A new repo

Before its first task, give the repo, on its default branch (no-mistakes reads
these only from there):

1. `.no-mistakes.yaml`, from `no-mistakes/repo.no-mistakes.yaml` with the
   repo's test and lint commands filled in.
2. `.github/pull_request_template.md`, from `no-mistakes/pull_request_template.md`.
3. A verification skill at `.agents/skills/verify-<app>/`, made with
   `create-verification-skill`.

Then run `no-mistakes init` in the repo and tell the first mate to add the
project.

## After an update

`no-mistakes update` and `/stow` may replace a link with a plain file. Re-run
`scripts/link-machine.sh`: it moves any such file aside to `<file>.bak`, so
diff that against this repo's copy and keep what changed.
