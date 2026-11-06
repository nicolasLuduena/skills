---
name: code-review
description: "Four-axis review since a fixed point (commit, branch, tag, or merge-base): Standards (does the code follow this repo's documented coding standards?), Spec (does it match what the originating issue/spec asked for?), Quality (does the change hold up?) and Audit (what is wrong in the code around it?). Runs all four in parallel sub-agents and reports them side by side. Use when asked for a Standards/Spec review, or \"review since X\"."
metadata:
  fork:
    change: "Asks only without a remote, so it runs unattended: defaults the fixed point, the spec and the tracker, and narrows the description so it stops overlapping ponytail-review. Standards always flags ADR citations in added comments as hard violations, since agents keep writing them. Quality and Audit axes run ponytail-review and ponytail-audit by reading their SKILL.md, since both are user-invoked."
---

Four-axis review of the diff between `HEAD` and a fixed point:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?
- **Quality**: does the change hold up: bugs, security, load, tests, speed, bloat? (`ponytail-review`)
- **Audit**: what was already wrong in the folders the change touches? (`ponytail-audit`)

All axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

The issue tracker should have been provided to you. If not, use `gh` on the repo's `origin`.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If none was given, use the PR's base (`origin/<baseRefName>` from `gh pr view`) when this branch has a PR, else `origin/HEAD` (`git remote set-head origin -a` if it's unset). Ask only when there is no remote either.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside the parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in the tracker doc.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. The issue the branch was cut for: `<n>` in an `agent/<repo>-<n>` branch name, or the PR's linked issue.
5. If nothing is found, don't ask: the **Spec** sub-agent skips and reports "no spec available".

### 3. Identify the standards sources

Search the repo for every file that documents how code should be written. When `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it must be on the list.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of code smells, mostly Fowler's (_Refactoring_, ch.3), that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic, constant, path, or test appears twice, within the change or between it and existing code, including across languages (a shell script and a TS file); or the change hand-rolls what the standard library or an existing helper already does. → extract the shared shape and call it from both, or use what exists. Skip repeats so small that extracting them only adds indirection.
- **Dead Code**: an export nothing imports, a field nothing reads, a parameter nothing passes, a branch nothing reaches, or a dependency or script nothing uses. → delete it. Not dead: a library's public API, framework entry points, anything loaded by name.
- **Lazy Element**: a function, type, or local that adds nothing over its contents, such as a helper with one trivial caller or a local used once with no better name than its expression. → inline it. Keep it when its name explains a step or it's a test seam.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

The Standards axis also always carries one **fixed rule**, a hard violation even when the repo documents nothing about comments:

- **No ADR citations in comments**: a comment the diff adds that names the decision it implements (`// Implements ADR-0007`, `# per ADR 3: event-sourced orders`). The ADR and git history already record that, and the comment rots when the ADR is superseded. → delete the citation; keep the rest of the comment only if it still explains the code on its own.

### 4. Spawn the sub-agents in parallel

Issue all the sub-agent calls together, in the foreground, and aggregate the reports they return.

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline and the fixed rule from step 3** pasted in full (the sub-agent has no other access to them).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); (b) any baseline smell you spot: name it and quote the hunk; and (c) every ADR citation the diff adds to a comment, as a hard violation whose fix is deleting it. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Read each changed file in full, not only its hunks, because duplication and dead code hide outside them. Confirm every claim that something is unused with a repo-wide search before reporting it. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

**Quality** and **Audit** run two user-invoked skills, so the sub-agent reads each file instead of loading it. Both files sit beside this skill's directory. If one is missing, skip its axis and note this in the final report.

**Quality sub-agent prompt** should include:

- The diff command and commit list.
- The absolute path of `ponytail-review/SKILL.md`.
- The brief: "Read that file and follow it, reviewing this diff."

**Audit sub-agent prompt** should include:

- The folders the diff touches: the parent directory of each file in `git diff --name-only <fixed-point>...HEAD`, without repeats.
- The absolute path of `ponytail-audit/SKILL.md`.
- The brief: "Read that file and follow it, auditing only these folders. Leave out what the diff itself introduced: the Quality axis reports that."

### 5. Aggregate

Present the reports under `## Standards`, `## Spec`, `## Quality` and `## Audit` headings, verbatim or lightly cleaned. Open `## Audit` with "Already in the code, not for this change to fix.": whoever acts on this review leaves those findings alone. Do **not** merge or rerank findings, because the axes are deliberately separate (see _Why separate axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why separate axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

- Code that follows the standards and the spec can still crash on an empty list → **Standards and Spec pass, Quality fail.**

Reporting them separately stops one axis from masking another.
