# PR Autopilot for Claude

A Claude Code plugin that polls GitHub for new reviews, comments and CI
results. When those arrive, they're forwarded to the Claude instance running
locally on the same Git branch.

## Requirements

- **Claude Code with the plugin hooks API** (2.1.294 or newer).
- **The BBGitHub MCP server**, connected in Claude Code as `bbgithub`. Check
  that `/mcp` lists it as connected. The plugin calls it with the session's
  own connection, so there is no separate login and no permission prompt.

## Setup

Install it from this repo:

```sh
claude plugin marketplace add https://bbgithub.dev.bloomberg.com/nrubin19/claude_pr_autopilot.git
claude plugin install pr-autopilot@pr-autopilot
```

To update to the latest version:

```sh
claude plugin marketplace update pr-autopilot
claude plugin update pr-autopilot@pr-autopilot
```

## Config

By default, the plugin asks Claude to use the skills it ships in `./skills`. To change that or any other option, run this in Claude:

```
/plugin configure pr-autopilot@pr-autopilot
```

Every option is optional. Set only the ones you want to change. The general
options are below; feedback and CI options are in their own sections.

| Option | Default | |
| --- | --- | --- |
| `mcpServer` | `bbgithub` | BBGitHub MCP server name, as `/mcp` lists it |
| `intervalSeconds` | `10` | How often each session checks; the poller's request rate |

## PR Feedback Autopilot

When PR reviews are submitted on Github, your local Claude instance on the same
Git branch is notified to address it.

### Config

| Option | Default | |
| --- | --- | --- |
| `feedbackAutomationEnabled` | `true` | Whether new reviews and comments on your PR are sent to Claude. Feedback that arrives while this is off is never sent. |
| `feedbackSkill` | `pr-autopilot:address-pr-feedback` | Skill Claude is told to use for PR feedback: its name (`my-pr-feedback`) or its folder (`~/.claude/skills/my-pr-feedback`). |
| `feedbackTriggerOnlyInRealTime` | `false` | What happens to feedback posted while no Claude session is running for that PR's branch. `false`: it waits, and the next Claude session started on the branch will immediately start processing it. `true`: it's skipped. |

### Commenting on your own PR

Prefix a comment with `/claude` or `@claude`, e.g. `/claude rename this to
isDone`, to have it sent to Claude. Your other comments, like replies to
reviewers, are ignored.

### The bundled skill

The plugin ships a skill, `pr-autopilot:address-pr-feedback`
(`skills/address-pr-feedback/SKILL.md`), and every feedback prompt asks Claude
to use it. It uses the bbgithub MCP tools and follows these rules:

- **Feedback only from pr-review-bot:** address it, push, reply to and resolve
  the comments, and re-request a review, so the pr-review-bot and Claude
iterate on their own.
- **Feedback from people:** make local changes only. Never push or reply.
- **Your own `/claude` instructions:** follow them as written, including posting
  on GitHub.

## CI Completion Autopilot

When CI steps on Github complete, your local Claude instance on the same Git
branch is notified to address it.

### Config

| Option | Default | |
| --- | --- | --- |
| `ciAutomationEnabled` | `true` | Whether CI results on your PR are sent to Claude. CI that finishes while this is off is never sent. |
| `ciSkill` | `pr-autopilot:address-ci-results` | Skill Claude is asked to use for CI results, given the same way as `feedbackSkill` |
| `ciTriggerCadence` | `onAllChecksFinish` | When CI results are sent. `onAllChecksFinish`: one prompt once every check on the PR's latest commit has finished. `onSingleCheckFinish`: a prompt each time a check finishes |
| `onlyTriggerWhenCiFailed` | `true` | `true`: CI results are sent only when a check failed (`failure`, `error`, `timed_out`, `action_required`). If `onAllChecksFinish` is set to true and some checks failed, ALL checks and their statuses are sent to Claude. `false`: pass check status to Claude whether they passed or failed. |
| `ciTriggerOnlyInRealTime` | `false` | What happens to CI results that arrive while no Claude session is running for that PR's branch. `false`: they wait, and the next Claude session started on the branch will immediately start processing them. `true`: they're skipped. |

### When results are sent

- **`onAllChecksFinish`:** CI counts as finished once nothing is pending and at
  least 2 minutes have passed since the plugin first saw the commit, because
  some CI posts its first status a minute after the rest. A check that only
  shows up later than that is missed.
- Re-running a build without a new commit (e.g via the Jenkins UI) will not
  cause Claude to react. A new commit is always needed.
- The plugin stops watching a commit 2 hours after first seeing it, even if
  some checks never finish.

### The bundled skill

CI prompts use `pr-autopilot:address-ci-results`
(`skills/address-ci-results/SKILL.md`). If everything passed, it says so. If a
check failed, it reads the failure, says whether this branch caused it, and
fixes it locally. It never pushes or comments.

## Usage reporting

The first session on each machine adds a 👍 from your bbgithub account to the
[install tracker comment](https://bbgithub.dev.bloomberg.com/nrubin19/claude_github_comments_plugin/issues/1#issuecomment-15552086),
so the author can see who uses the plugin. That's all it sends: no repo, PR or
comment data.

## Troubleshooting

Run `/pr-watch`. It shows the branch, the matched PR, which session is the
poller, the last error, how many items are waiting in the inbox, and the last
10 delivered.

Errors never go to the transcript. Each time one starts or clears, a line goes
to `~/.local/state/pr-feedback-watcher/errors.log` (moved to `errors.log.1`
past 256 KB). An error that lasts over 3 minutes also shows on the status line
until it clears. A bbgithub call that hasn't answered within 60 seconds counts
as failed.

Common causes:

1. **`PR: no open PR of yours for this branch`**: the PR isn't open, isn't
   yours, or the branch/repo name doesn't match the local checkout. A brand-new
   PR shows up after the poller's next tick.
2. **`bbgithub-... failed`** or an unknown-server error: check that `/mcp`
   shows the BBGitHub server connected, under the name set in `mcpServer`.
   Only the poller calls bbgithub, so this error shows in that session.

3. **`couldn't read <PR url>: ...`**: that one PR failed. It's retried every
   tick, and the other PRs keep working. Replies over Claude Code's MCP output
   limit (big PRs with many inline threads) are handled: the plugin reads the
   full reply from the file Claude Code saves it to.

To look at the state directly:

```sh
cd ~/.local/state/pr-feedback-watcher
cat poller.lock/heartbeat   # which session polls, and when it last renewed
cat prs.json                # my open PRs, as of the last poll
ls inbox/*/ inbox-ci/*/     # feedback / CI results waiting for a session on that branch
cat delivered/*/*.json      # feedback sent, when, and to which session
```

Files are named by a hash of the PR or comment URL.

## How it works

Every session runs the same 10-second tick:

1. **Lease.** It tries `mkdir poller.lock`. If that succeeds, or the
   `heartbeat` inside names this session, it is the poller and rewrites the
   heartbeat. If someone else's heartbeat is over 30 seconds old, that session
   died: it runs `mv poller.lock poller.lock.dead.<id>`, which only one session
   can win, and retries the `mkdir`. A session that exits normally deletes
   `poller.lock`, so the next session takes over within one tick. The
   heartbeat also records the poller's plugin version: a session running a
   newer version takes over at once, so sessions started before an upgrade
   stop polling with the old code.
2. **Poll (poller only).** One `bbgithub-search-issues-and-pull-requests` call
   for `is:pr is:open author:@me`. For each PR whose `updatedAt` changed since
   `prs.json`, one `bbgithub-pr-read` (view, review summaries and top-level
   comments, paged by 100). Inline comments on the code are read with a second
   call, and only when a review has arrived since the last read: every inline
   comment (one-off, in a full review, or a reply) comes with a review, and the
   threads are big, since each carries a diff hunk. Then, for each PR that
   changed or whose CI is still running, one `bbgithub-pr-read` for its checks
   (CI results don't change `updatedAt`). Each new review, comment or CI result
   not in `seen/` becomes a file in
   `inbox/<pr>/` (CI results: `inbox-ci/<pr>/`, which versions before 0.5.0
   don't read), then gets a marker in `seen/<pr>/`. The first time a PR is
   seen, its existing feedback is only marked seen. Closed PRs' inbox folders
   are deleted.
3. **Deliver (every session).** It finds its branch's PR in `prs.json` and
   claims each `inbox/<pr>/` and `inbox-ci/<pr>/` file with `mv` into `delivered/<pr>/`. Only one
   session's `mv` can succeed. It then sends one prompt with what it claimed,
   using `$.prompt.submit`, which starts a turn once the session is idle.

It skips unsubmitted reviews, and skips your own comments unless they start
with `/claude` or `@claude`.

### Why it's safe with many sessions

- **Shared state only changes with `mkdir` and `mv`.** Both are atomic, so if
  two sessions try the same one, exactly one succeeds. No file is read,
  modified and written back.
- **Feedback isn't lost.** An item goes into the inbox before it's marked seen.
  If the poller crashes in between, the next poller files it again. The worst
  case is a duplicate prompt.
- **Nothing waits on a dead session.** A dead poller is replaced within about
  40 seconds. Undelivered feedback waits in the inbox until a session on that
  branch starts.
- **Known edge case.** A poller that freezes for over 30 seconds without
  exiting (e.g. the laptop sleeps) is replaced. When it wakes, it may make one
  extra request before it sees the new heartbeat.

## Releasing a change

`claude plugin update` only installs a new copy when `version` in
`.claude-plugin/plugin.json` changes. Bump it in the same push as the change,
or installed copies keep running the old code.

## Developing

To run a local checkout instead of the installed copy, uninstall it
(`claude plugin uninstall pr-autopilot@pr-autopilot`), then run:

```sh
claude --plugin-dir /path/to/claude_github_comments_plugin
```

Edits reload while the session runs.

## Tests

```sh
claude plugin validate .
claude plugin test .
```
