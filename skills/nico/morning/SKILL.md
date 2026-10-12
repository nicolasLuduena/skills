---
name: morning
description: "Write the Morning summary from nico-agent status since the last one: what to merge in which order, what needs the user, and what the night did."
disable-model-invocation: true
---

# Morning

You write the user's **Morning summary**, the one thing they read with coffee: which PRs to merge and in which order, what needs them, and what the loop did while they were away. nico-agent, the loop that works through issues overnight, starts you once a day. Your prompt names the `nico-agent status --json --since <time>` command that holds the night and the path to write the summary to. `<time>` is when the last summary was started; "since last time" below means after it.

Your one write is that file. nico-agent's other files, the Repos and the issue trackers stay as you found them. Nobody reads your turn live: the file is the whole result.

## 1. Read the night

Run the command your prompt gives, verbatim. When it fails, end your turn with its output and write nothing.

Its JSON holds, among other fields:

- `dispatches[]`: every **Dispatch** (one issue sent to one Implementer agent), live and Closed, oldest first. Each has `issue` (its key: `owner/repo#N`, or a Linear key like `BLE-12`), `url` (the issue's), `title`, `repo`, `branch`, `base` (the branch its PR targets), `stage` (`Implementing`, `PR draft`, `Verified`, `Merged`, `Closed` or `Failed`), `pr` (its PR as last seen, with `url`, or null), `stacked_on` (the PR it was started on, with `url` and `head_branch`; its PR still sits on that one while `head_branch` is its `base`), `asking` (`{since, question}` while its agent waits on the user), `failure` (`{step, error, reason}`, `reason` optional) and `restarts` (`{at, reason, by}`, oldest first).
- `merged[]` and `closed[]`: the Dispatches whose PR merged since last time, and those Closed since last time without merging. Same shape.
- `answers[]`: each answer typed into a waiting agent since last time, `{issue, question, text, by}`, `by` being `user` or `faux-nico`.
- `scans[]`: each quality-scan run since last time, with its `repo`.

Done when the command printed JSON and you hold these lists.

## 2. Ask the Source

Two sections need what the issue tracker, the **Source**, holds. A key `owner/repo#N` is a GitHub issue, read with `gh` as below. A Repo whose keys are Linear keys has Linear as its Source: ask the Linear tool you have the same two things, an issue's labels and the issues created after `<time>` whose description contains `Filed by quality-scan.`

- **Gardening.** For each Dispatch in `merged` and `closed`, its labels: `gh issue view <its url> --json labels`. It is gardening when one of them is `gardening`.
- **Filed.** For each distinct `repo` in `scans`, the issues quality-scan filed there since last time:

  ```sh
  gh issue list --repo <repo> --state all --limit 100 \
    --search '"Filed by quality-scan" in:body created:><time>' \
    --json number,title,labels
  ```

Done when every Dispatch in `merged` and `closed` has its labels, and every scanned Repo its filed issues, maybe none.

## 3. Write the summary

Write the file at the path your prompt gives. It holds exactly six sections, in the order below, each a `## ` heading followed by either its list or, when nothing belongs in it, the one line given as its Empty, with a blank line between blocks. Nothing else goes in the file: no title, no prose between sections. Issues go by key and PRs by url, as status gives them.

nico-agent notifies the user with the file's first line that is not a heading, so the first PR to merge, or `Nothing to merge`, leads.

**`## Merge these`**: every Dispatch whose `stage` is `Verified`, numbered: `1. <pr url> <issue key> <title>`. Group them by `repo`, the Repos in the order they first appear in `dispatches`. Within a Repo keep `dispatches` order, except that a PR comes after the PR it still sits on (`stacked_on.url`, while `stacked_on.head_branch` is its `base`). A PR sitting on a PR that is not in this list waits on that one: it goes last in its Repo, its line ending with `, stacked on <that PR's url>`. Empty: `Nothing to merge`.

**`## Answer these`**: every Dispatch with `asking` set: `- <issue key>: "<question>"`, an empty question written `(no question read)`. Empty: `Nothing needs you`.

**`## Fix these`**: every Dispatch whose `stage` is `Failed`: `- <issue key>: <reason>: <failure.error>`. The reason is `failure.reason`, else the `reason` of the last entry in `restarts`, else `<failure.step> failed`. Empty: `Nothing needs you`.

**`## Landed`**: in the order status lists them, every Dispatch in `merged`, as `- <pr url> <issue key> <title>`, then every one in `closed`, as `- <issue key> <title>, Closed unmerged`. A gardening one ends with ` [gardening]`. Empty: `Nothing ran`.

**`## Filed`**: every issue from step 2, grouped by label, the ones labelled `gardening` first, then `needs-triage`, then the rest: `- <repo>#<number> <title> [<labels, comma-separated>]`. Empty: `Nothing ran`.

**`## faux-nico said`**: every entry in `answers` whose `by` is `faux-nico`: `- <issue key> asked "<question>", faux-nico said: <text>`. Empty: `Nothing ran`.

A night with two stacked PRs to merge, one question waiting and one gardening issue landed:

```markdown
## Merge these

1. https://github.com/acme/shop/pull/40 acme/shop#12 Add the cart total
2. https://github.com/acme/shop/pull/41 acme/shop#13 Show the total in the header

## Answer these

- acme/api#9: "Keep the v1 endpoint, or drop it?"

## Fix these

Nothing needs you

## Landed

- https://github.com/acme/shop/pull/38 acme/shop#10 Delete the unused retry option [gardening]

## Filed

Nothing ran

## faux-nico said

Nothing ran
```

Done when the file holds the six headings in order, each followed by its list or its one empty line, and every Verified, Asking and Failed Dispatch, every Dispatch in `merged` and `closed`, every filed issue and every faux-nico answer has its line.
