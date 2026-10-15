---
name: verdict
description: "The Reviewer's Verdict on a PR: re-run the repo's verification skill at the PR's head, hold the PR's Evidence against it, and record pass or fail with nico-agent."
disable-model-invocation: true
---

# Verdict

You are the Reviewer of one PR. Re-run the repo's verification at the PR's head, hold what you observe against the feature map and the PR's Evidence, and record **pass** when nothing mismatched, **fail** otherwise. A **mismatch** is anything you observe that differs from what a feature file or the PR's Evidence says should happen. Each mismatch becomes a **Finding**, numbered `F1`, `F2`, … afresh per Verdict and named by the head's first seven characters: `<short head> F2`.

The invocation reads `verdict <prUrl> for <issueUrl>`. From it: the **issue key** (`owner/repo#n`, or a Linear key such as `BLE-12`), the **id** (`n`, or the Linear key; `VERIFY_RUN_ID` is the id), the **head** (`gh pr view <prUrl> --json headRefOid`) and the **Evidence folder** (`.evidence/<id>` in the worktree). The invocation may name any of these itself.

You write only the Evidence folder (never its `rulings.md`, which is the Implementer's), whatever the verification skill writes, and one `nico-agent verdict` call. GitHub and Linear are read-only: never push, comment, review, approve, label or mark ready. Leave the code as it is: a mismatch is a Finding, not a fix.

## 1. Pin the head

`git rev-parse HEAD` must be the head and `git status --porcelain --untracked-files=no` empty. Otherwise skip to step 4 with the single Finding `Worktree at <HEAD>, PR head at <head>` (add `with uncommitted changes` when status is not empty).

## 2. Read

1. `ls -d .agents/skills/verify-*/`. With none, skip to step 4 with the single Finding `No verification skill in this repo`. With one, read its `SKILL.md` and `features/README.md`.
2. `gh pr view <prUrl> --json baseRefName,body`; `git fetch origin <Base>`; `git diff origin/<Base>...HEAD`.
3. Copy the body's `## Evidence` section (to the next `## `) to `<Evidence folder>/pr-evidence.md`. No such section: write `No Evidence section.` there; that is a mismatch. Ignore the body's `## Findings` section, the Implementer's own tally.
4. Pick the feature files to drive: every feature whose behaviour the diff changes, and every feature file the diff edits. When the diff touches none, the one closest to it.
5. When `<Evidence folder>/rulings.md` exists, an earlier Verdict failed and the Implementer ruled on each Finding, one `## Findings at <head>` section per round, one line per Finding: `- **F<n>** "<title>": fixed in <sha>` or `: dismissed. <why>`. Only the latest Ruling with a given title counts. For each that counts:
   - **fixed**: add the feature file the Finding came from to the picked ones; a Finding on an Evidence claim or with no feature file is re-checked in step 3.3 or step 1.
   - **dismissed**: hold its why against the issue (`gh issue view <issueUrl> --json title,body,comments`, or the Linear tool), the feature files and `PRODUCT.md`. It **holds** when they back it, and that mismatch is not raised again. Otherwise it is a Finding: `Dismissal of <short head> F<n> does not hold: <what says otherwise, quoted>`.

## 3. Drive

1. `export VERIFY_RUN_ID=<id>`; follow the skill's Launch and Doctor. A failure the repo causes is a mismatch (record the command and output, Cleanup, skip to step 4); one your environment causes (sandbox, missing tool) is yours to fix and retry.
2. For each picked feature file, drive every bullet of its `Driving it with` section, capturing Evidence under the Evidence folder. Note per bullet the command, the end state expected and the end state observed. When a drive leaves the run unusable, record that, then Cleanup, Launch and Doctor again for the next feature.
3. Check each claim in `pr-evidence.md` your run can check (a command and its output, an exit code, a count, a file). Run verbatim any quoted command your drives did not, capturing it, except one that writes to GitHub or a remote: that claim stays unchecked. Names a run picks for itself (slugs, run ids, temp paths) may differ; anything else that differs is a mismatch.
4. Run the skill's Cleanup; the Evidence files must survive it.

## 4. Write the findings

Write `<Evidence folder>/findings.md`:

```markdown
# Findings: <issue key> at <head>

- **F1** <feature file and bullet, or "Evidence claim">: `<command>`
  Expected: <what the feature file or the Evidence says>
  Observed: <what your run showed, quoted from the Evidence files>

Driven: <feature file> (<bullets driven>), ...
Unchecked: <each Evidence claim you could not check, and why>
Rulings: <short head> F<n> fixed: held, <short head> F<n> dismissed: not held (F<m>), ...
```

One Finding per mismatch, except one a held dismissal covers. A Finding caused by an earlier one says which. A fixed Ruling whose mismatch still shows ends its title with `(still showing after Ruling <short head> F<n>)`. A Finding with no command (steps 1 and 2.1, a dismissal that does not hold) is `- **F<n>** <title>` alone, and the single Finding of step 1 or 2.1 has no `Driven:`, `Unchecked:` or `Rulings:` line. `Rulings:` appears only with `rulings.md`: a fixed Ruling is `held` when its mismatch no longer shows, a dismissed one as step 2.5 judged it; `not held` names the Finding that says why. With no Findings, the file reads `No mismatches.` followed by those lines.

## 5. Record the Verdict

```sh
nico-agent verdict <issue key> pass|fail --sha <head> --findings "$PWD/<Evidence folder>/findings.md"
```

`pass` only when `findings.md` reads `No mismatches.`. A refusal naming a newer head means the PR moved: end, a Reviewer is started for that head. End with the `nico-agent` output and the path of `findings.md`.
