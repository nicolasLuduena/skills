---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
metadata:
  fork:
    change: "An out-of-scope question before the frontier closes. Implementation rounds: once the product tree is settled for a code plan, offer a second layer of questions on modules, interfaces, seams, data, state, failure and tests, so to-spec's Implementation and Testing Decisions come from the interview, not from guesswork."
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

Before declaring the frontier empty, put the **out of scope** list to the user as one question: what you propose to leave out, so that "yes" accepts it. The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.

## Implementation rounds

When the plan is code and the product frontier is empty, offer one more layer: ask whether to grill the implementation too, and finish the session as usual if the answer is no. If yes, call `codebase-design` and use its words. Explore the repo first, so each recommended answer names code that exists. Each question body carries what the code does today in that area and the candidate shapes with their trade-offs, so the user can decide from the question alone. Skip markup and styling. The frontier is not empty while any of these is unasked:

- **Modules**: which are new, which change, and any dependency added.
- **Interface** of each: calls, input and output shapes, invariants, error modes.
- **Seam**: where tests cross, existing or new, and the adapter that stands in for each dependency.
- **Data**: persisted shapes, schema changes, who owns each.
- **State**: where it lives, who mutates it, in what order.
- **Failure**: what each dependency failing does to the caller.
- **Tests**: which behaviours get a test, through which interface, at what level (unit, integration, end to end), prior art in the repo.
