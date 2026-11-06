---
name: vertical-slicing
description: Rules for cutting work into vertical slices where each PR defines only what it uses. Use when splitting a spec or plan into tickets or PRs, deciding which ticket a function, constant, class, type or schema change belongs to, or when another skill needs the slicing rules.
---

# Vertical Slicing

One ticket is one PR, and a human reviews each PR **alone**: no earlier PR fresh in mind, no later PR in sight. A PR earns its merge from what is inside it. Cut the work so each is a **vertical slice**, and place every definition by **first use**.

## Vertical slice

- A slice cuts a narrow but COMPLETE path through every layer it needs (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer.
- Merged alone, a slice is demoable or verifiable through behaviour it makes work.
- A slice fits in a single fresh context window.

Thin a slice by behaviour, never by layer: one case, one field, the happy path first. The next case is the next slice.

## First use

A **definition** is anything a PR adds that other code can refer to: a function, constant, class, type, field, column, table, endpoint, config key, flag, dependency.

Every definition lands in the slice that first uses it. A use is a path from the behaviour the slice delivers to the definition; a test alone is not a use. So at each slice's merge, deleting any definition it added would break behaviour it delivers, and the reviewer sees why it exists without opening another PR. The deletion test from `codebase-design` applies PR by PR.

What follows:

- Layers grow slice by slice. The first slice adds only the columns, fields and parameters its one case reads or writes; later slices add theirs.
- A ticket whose job is the helpers, the types or the foundation does not exist. Its contents move into the slices that use them.
- When two slices need the same definition, the one that lands first defines it and blocks the other. The shared definition is the blocking edge; the ticket says so.
- A prefactor reshapes code that is already called, and every name it introduces is used when it merges. A seam or parameter that only a later slice needs belongs to that slice.
- A wide refactor's expand ships with its first migrate batch, so the new form lands with a caller.

## When a cut cannot be vertical

Some work has no thin end-to-end path: a contract two teams meet at, a build or infrastructure step with no user-visible surface. Then cut horizontally on purpose:

- The ticket says it is a horizontal cut, why, and which ticket consumes it, in words the PR body carries to the reviewer.
- What lands unused is the one interface that consumer needs, no wider.
- That consumer is blocked on it, so the unused interface lives for one merge.

## Check

Before a breakdown is shown, for every slice:

1. Name the behaviour that works once it merges alone.
2. For every implementation decision the spec assigns to it (module, interface, schema change, contract), name the path inside the slice that uses it. One without a path moves to the slice that has one, or shrinks to the part this slice uses.
3. Confirm each blocking edge is a definition or behaviour the slice uses, and that every such definition has an edge.

Done when every slice passes all three, or carries the horizontal-cut note.
