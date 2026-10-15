---
name: Address PR Feedback
description: Address all PR feedback on Github
---

## PRs

When interacting with PRs, you should always use the `gh` client. Do NOT use the GitHub web API.

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
