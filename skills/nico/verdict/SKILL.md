---
name: verdict
description: "The Reviewer's Verdict on a PR: re-run the repo's verification skill at the PR's head, hold the PR's Evidence against it, and record pass or fail with nico-agent."
disable-model-invocation: true
---

# Verdict

You are the Reviewer of one PR. Re-run the repo's verification at the PR's head, hold what you observe against the feature map and the PR's Evidence, and record a Verdict: **pass** when you drove the verification and nothing mismatched, **fail** otherwise. A **mismatch** is any place where what you observe differs from what a feature file or the PR's Evidence says should happen.

The invocation reads `verdict <prUrl> for <issueUrl>` and may also name the issue key, the head and the Evidence folder. Take each from the invocation when it names it, otherwise:

- **issue key**: `<owner>/<repo>#<n>` from the issue URL (a Linear issue keeps its key, `BLE-12`).
- **id**: `<n>` (or the Linear key). `VERIFY_RUN_ID` is the id.
- **head**: `gh pr view <prUrl> --json headRefOid`.
- **Evidence folder**: `.evidence/<id>`, in the worktree.

Your writes are the Evidence folder, whatever the verification skill itself writes, and the one `nico-agent verdict` call. GitHub is read-only to you: read the PR with `gh pr view` and the issue with `gh issue view`, never push, comment, review, approve, label or mark it ready. Leave the code as the Implementer left it: a mismatch is a Finding, never a fix.

## 1. Pin the head

You are in the Dispatch's worktree. Run `git rev-parse HEAD` and `git status --porcelain --untracked-files=no`.

Done when HEAD is the head and no tracked file is modified. When either fails, the worktree is not the PR: skip to step 5 with the single Finding "Worktree at `<HEAD>`, PR head at `<head>`" (add "with uncommitted changes" when status is not empty).

## 2. Find the verification skill

`ls -d .agents/skills/verify-*/`. With none, skip to step 5 with the single Finding "No verification skill in this repo".

With one, read its `SKILL.md` and `features/README.md`. Done when you know its Launch, Doctor, Evidence and Cleanup sections and its list of feature files.

## 3. Read the diff, the Evidence and the Rulings

1. `gh pr view <prUrl> --json baseRefName,body` gives the Base and the PR body.
2. `git fetch origin <Base>`, then `git diff --stat origin/<Base>...HEAD` and `git diff origin/<Base>...HEAD`.
3. Copy the PR body's `## Evidence` section, from its heading to the next `## `, to `<Evidence folder>/pr-evidence.md`. With no such section, write `No Evidence section.` there instead: that is a mismatch. The body's `## Findings` section is the Implementer's tally of its Rulings, not Evidence: nothing in it is checked.
4. Pick the feature files to drive: every feature whose behaviour the diff changes, and every feature file the diff itself edits. When the diff touches none, pick the one closest to it.
5. When `<Evidence folder>/rulings.md` exists, an earlier Verdict failed and the Implementer wrote a **Ruling** on each of its Findings. Under each `## Findings at <head>` heading, one line per Finding reads `- **F<n>** <the Finding's title>: fixed in <commit sha>` or `: dismissed. <why>`. A Ruling is named `<short head> F<n>`, the short head being that head's first seven characters. Only the last Ruling in the file on a Finding counts. For each that counts:
   - **Fixed:** add the feature file the Finding came from to the picked ones, its reason `Ruling <short head> F<n>: fixed`.
   - **Dismissed:** hold its why against the issue (`gh issue view <issueUrl> --json title,body,comments`, or the Linear tool for a Linear key), the feature files and `PRODUCT.md` at the worktree's root when there is one. It **holds** when they back it, and that mismatch is not raised again. It **does not hold** otherwise, and that is a Finding: "Dismissal of `<short head> F<n>` does not hold: <what says otherwise, quoted>".

Done when `pr-evidence.md` exists, the picked feature files are listed, each with the reason it was picked, and, with `rulings.md`, every dismissal that counts is marked held or not held.

## 4. Drive

1. `export VERIFY_RUN_ID=<id>` and follow the skill's Launch and Doctor sections. A launch or doctor that fails because of the repo is a mismatch: record its command and output, run Cleanup, and skip to step 5. One that fails because of your own environment (a sandbox denial, a tool missing on this machine) is yours to fix and retry.
2. For each picked feature file, drive every bullet of its `Driving it with` section, capturing Evidence where the skill says under the Evidence folder. Against each bullet, note the command, the end state the feature file expects, and the end state you observed. When a drive leaves the run unusable for the next feature, record that as a mismatch, then Cleanup, Launch and Doctor again so the next feature still gets driven.
3. Take each claim in `pr-evidence.md` your run can check (a command and its output, an exit code, a count, a file, a state left unchanged). Run any command a claim quotes that your drives did not, verbatim, capturing it under the Evidence folder; a quoted command that writes to GitHub or a remote stays unrun, and its claim unchecked. A claim holds when your run shows the same behaviour; names a run picks for itself (slugs, run ids, temp paths) may differ. A claim your run contradicts, or a command that does not do what the claim says, is a mismatch.
4. Run the skill's Cleanup.

Done when every bullet of every picked feature file has an observed end state, every checkable claim is marked held or mismatched, and the Evidence files still exist after Cleanup.

## 5. Write the findings

Write `<Evidence folder>/findings.md`, one **Finding** per item, numbered `F1`, `F2`, … in the order written:

```markdown
# Findings: <issue key> at <head>

- **F1** <feature file and bullet, or "Evidence claim">: `<command>`
  Expected: <what the feature file or the PR's Evidence says>
  Observed: <what your run showed, quoted from the Evidence files>

Driven: <feature file> (<bullets driven>), ...
Unchecked: <each Evidence claim your run could not check, and why>
Rulings: <short head> F<n> fixed: held, <short head> F<n> dismissed: not held (F<m>), ...
```

The numbers start again at `F1` each Verdict, so a Finding is named by its head and number: `<short head> F2`.

One item per mismatch and per dismissal that does not hold. A mismatch a held dismissal covers is not an item. A mismatch caused by an earlier one says which; one a fixed Ruling covers that still shows says so after its title: `(still showing after Ruling <short head> F<n>)`. A Finding with no command (a dismissal that does not hold, worktree not at the head, no verification skill) is its title alone. The single Finding of step 1 or 2 has no `Driven:`, `Unchecked:` or `Rulings:` line.

The `Rulings:` line comes only when `rulings.md` exists: each Ruling that counts, `held` or `not held`. A fixed one holds when its mismatch no longer shows, a dismissal as step 3 judged it; `not held` names the Finding that says why.

With no Findings, the file reads `No mismatches.` followed by the `Driven:` and `Unchecked:` lines, and the `Rulings:` line when there is one.

Done when every mismatch you noted in steps 3 and 4 is a numbered Finding, unless a held dismissal covers it; every dismissal that does not hold is one too; every Evidence claim is either held, a Finding, or on the `Unchecked:` line; and, with `rulings.md`, every Ruling that counts is on the `Rulings:` line.

## 6. Record the Verdict

```sh
nico-agent verdict <issue key> pass|fail --sha <head> --findings "$PWD/<Evidence folder>/findings.md"
```

`pass` when `findings.md` reads `No mismatches.`, `fail` otherwise. A refusal naming a newer head means the PR moved: end, a Reviewer is started for that head.

- **Pass** is done when `findings.md` reads `No mismatches.` with every driven feature file on its `Driven:` line and, with `rulings.md`, every Ruling `held` on its `Rulings:` line, and `nico-agent` printed `verdict: <issue key> pass at <head>`.
- **Fail** is done when `findings.md` holds one numbered Finding per mismatch and per dismissal that does not hold, each with its command, expected and observed, or its title alone, and `nico-agent` printed `verdict: <issue key> fail at <head>`.

End with the `nico-agent` output and the path of `findings.md`.
