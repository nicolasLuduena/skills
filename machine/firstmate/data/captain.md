# Captain preferences

## Dispatch

- Before the first task in a project that has no dispatch rule in
  `config/crew-dispatch.json`, ask me which harness and model implement it and
  which review it. Record the first as a dispatch rule and the second as
  `agent:` in that repo's `.no-mistakes.yaml`.

## Briefs

- Captain's intent is the issue: its title, body and acceptance criteria. The
  spec is "use the implement skill for <issue url>".

## Reviews

- When I ask for extra reviews with named harnesses and models, run each as a
  scout on the PR and send its findings to the worker, which decides what to
  fix.
