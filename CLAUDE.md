Skills live under `skills/` in three folders: `loop/` (what nico-agent's prompts call, and what those skills call), `verify/` (the two pstack skills) and `hand/` (user-invoked). `README.md` lists what belongs where; keep it true when a skill moves.

A skill is a folder with a `SKILL.md` and an `agents/openai.yaml`. A `SKILL.md` is user-invoked (`disable-model-invocation: true` in its frontmatter and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`) or model-invoked (neither). One copied or edited from upstream records what changed and why under `metadata.fork` in its frontmatter, where the agent never reads it; `FORK.md` keeps the table of those.

Prose stays short: an agent reads the whole file every time it is called. Cut before you add. No em-dashes anywhere in this repo's prose; rewrite the sentence with a comma, colon, period or parentheses instead.

After adding, removing or renaming a skill, run `scripts/link-skills.sh`.

## Agent skills

### Triage labels

Canonical names, unchanged: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`.
