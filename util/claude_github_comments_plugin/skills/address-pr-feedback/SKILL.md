---
name: address-pr-feedback
description: Address new GitHub PR feedback (reviews, comments, /claude instructions) that the pr-feedback-watcher plugin relays to this session
---

## PRs

When interacting with PRs, use the bbgithub MCP tools (`mcp__bbgithub__*`), not the `gh` client.

Reads (`bbgithub-pr-read`, `bbgithub-issues-get`, ...) are loaded directly. Writes are behind `mcp__bbgithub__bbgithub-dispatch`: pass `toolName` and `params`, or only `toolName` to get its schema first. They include:

- `bbgithub-comments-create-reaction`: react to a comment. `params`: `commentUrl` (the comment's `htmlUrl`) and `content` (`+1`, `-1`, `laugh`, `confused`, `heart`, `hooray`, `rocket`, `eyes`).
- `bbgithub-issues-create-comment`: post a top-level PR comment.
- `bbgithub-pulls-create-review-comment-reply`: reply to a review comment.
- `bbgithub-pulls-resolve-review-thread`: resolve a review thread.
- `bbgithub-pulls-request-reviewers`: (re-)request a review.

Call `bbgithub-dispatch` with no arguments to list every write tool. Fall back to `gh` only if no bbgithub tool does the job, and say so.

NEVER start a GitHub comment with `/claude` or `@claude`. Comments you post appear as the PR author, and those prefixes would trigger another run.

**Instructions from the PR author** ("Instruction from the PR author:" in the prompt, from a
`/claude` or `@claude` comment): do what it says, including posting on GitHub if it asks,
even when the rules below would forbid it.

If you are asked to respond to comments on a PR, do the following:

1. Find the right PR by using the branch name.
1. Read the PR comments. *Only address unresolved comments*.
1. Make any code changes you deem to be correct/good. Use the improve-code skill for this.
1. Consider different approaches for achieving the same goal. When there are multiple approaches with different pros/cons, highlight them and ask for direction.

**If ALL unresolved comments are from the pr-review-bot**:
1. Commit and push the changes to Github.
1. Comment on all unresolved comments with any thoughts you have.
1. Resolve any comments that you addressed.
1. Re-request a review from the pr-review-bot

**else**:
1. NEVER push up the changes to GitHub.
1. NEVER respond to comments on Github.
1. ONLY make code changes locally.
