<!--
Skip preambles and keep prose brief. Use the domain words from GLOSSARY.md.
Place each visual next to the short text it supports.
-->

# Summary

<!--
The smallest view that makes the key point clear. Use one or a few, never all:
- logic or an algorithm: pseudocode in a ```text block
- runtime control flow: a call tree (submitForm > createSession > launchAgent)
- UI structure: a component tree with the state and module boundaries that matter
- file responsibility or a broad refactor: a shallow file tree with a comment per entry
- interaction or data flow: a ```mermaid sequenceDiagram
- what changes in a shape that already exists: a ```diff of that tree, file layout,
  call tree or control flow, with + and - lines
- mostly new code, or a copyable target shape: the whole block
Keep only the calls, files, props, states and boundaries a reader needs.
-->

# Evidence

<!--
Concrete proof that the change works, as a before and after:

- **Before:** <screenshot, output, or the failing test run>
  **After:** <screenshot, output, or the passing test run>

Screenshots are best when the change is visual. Otherwise show test results or
console output: the exact test that failed and now passes, as pseudocode.

Then one line per feature file the verification skill drove, quoting the command
and the end state it observed:

- **<feature file>:** <the command driven> → <the observed end state>

When the repo has no verification skill, write "No verification skill in this
repo" here, so its absence is visible.
-->

# Merge Danger

<!--
**Door:** one-way or two-way. A two-way door is cheap to walk back; destructive
or hard-to-reverse changes are one-way doors. Add a line on why when it isn't obvious.

**Blast Radius:** one word, then any ramifications worth naming: breakages for
consumers, layout shift, mobile responsiveness, data, migrations.
-->
