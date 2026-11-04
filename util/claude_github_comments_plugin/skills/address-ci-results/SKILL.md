---
name: address-ci-results
description: Address CI results (GitHub Actions check runs, commit statuses) on the session's PR that the pr-autopilot plugin relays to this session
---

## PRs

When interacting with PRs, use the bbgithub MCP tools (`mcp__bbgithub__*`), not the `gh` client.

To see CI details, call `mcp__bbgithub__bbgithub-pr-read` with `actions: ["checks"]`. It returns, for the PR's head commit (or the commits in `sha`), each check run with its conclusion, summary and line-level annotations, and each commit status with a link to its CI page.

NEVER start a GitHub comment with `/claude` or `@claude`. Comments you post appear as the PR author, and those prefixes would trigger another run.

## When CI results arrive

The prompt lists each finished check as `name: conclusion (link)`, and the commit it ran on.

1. If the commit isn't the branch's latest local commit, say so: the results may already be out of date.
1. **Everything succeeded** (or was `skipped`/`neutral`): say so in one line and stop.
1. **Something failed** (`failure`, `error`, `timed_out`, `action_required`):
   1. Read the failing checks' summaries and annotations with `bbgithub-pr-read`. Follow the link for anything they don't explain, if you can read it.
   1. Decide whether the failure comes from this branch's changes or from something else (a flaky test, CI infrastructure, a problem already on the base branch). Say which, and why.
   1. If it comes from this branch, fix it locally and run the relevant tests or linters locally.
1. `cancelled` checks: mention them, but don't act on them.

## Rules

1. NEVER push to GitHub.
1. NEVER comment on the PR, and never re-run CI.
1. ONLY make code changes locally.
