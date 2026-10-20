import type { EngineInterface, Register } from 'claude-code'

import {
  RECORD_FORMAT,
  buildMessage,
  feedbackOn,
  findPr,
  hash,
  isOlderVersion,
  lastReviewAt,
  parsePrUrl,
  remoteRepoNames,
  skillName,
  toPullRequest,
} from './feedback'
import type { Feedback, PrView, PullRequest, ReviewsPage, SearchItem } from './feedback'

// Every session ticks. Each tick, one session (the poller, holding the lease) asks bbgithub for
// new feedback on all my open PRs and drops it into per-PR inbox folders; every session then
// claims the inbox items for its own branch's PR. State lives in files under STATE_DIR, changed
// only with mkdir and mv (atomic), so sessions can't clobber each other. See README.md.

const COMMAND = 'pr-watch'
// Each user's plugin 👍s this comment once, so its reactions list who uses it.
const USAGE_COMMENT_URL =
  'https://bbgithub.dev.bloomberg.com/nrubin19/claude_github_comments_plugin/issues/1#issuecomment-15552086'
const STATE_DIR = '.local/state/pr-feedback-watcher' // under $HOME
// A lease whose heartbeat is older than this is taken over.
const LEASE_STALE_MS = 30_000
const PER_PAGE = 100
// After a PR fails to read, wait this long before trying it again.
const RETRY_FAILED_PR_MS = 5 * 60_000
// Stops paging through a PR's reviews/comments after this many pages.
const MAX_PAGES = 10

// `version` is the poller's plugin version; versions before 0.2.4 don't write it.
type Heartbeat = { sessionId: string; at: number; version?: string }
// `skipped` says why an item was claimed but not sent.
type Delivered = Feedback & { deliveredAt?: string; sessionId?: string; skipped?: string }

// Set by register() and session.start. A reload re-runs both, so these reset.
const config = {
  skill: 'pr-feedback-watcher:address-pr-feedback',
  mcpServer: 'bbgithub',
  intervalMs: 10_000,
  isRealTimeOnly: false,
}
const paths = { dir: '', lock: '', heartbeat: '', prs: '' }
let sessionId = ''
let version = ''
let startedAt = 0
// The branch on the last tick, and since when this session has been on it. With
// onlyTriggerInRealTime, feedback posted before onBranchSince is skipped.
let lastBranch: string | undefined
let onBranchSince = 0
const status: { isPoller?: boolean; branch?: string; prUrl?: string; lastTick?: string; error?: string } = {}
let isTicking = false
let hasTriedUsageReport = false
// PRs that failed to read: when to retry each, and the error to keep showing until then.
const failedPrs = new Map<string, { retryAt: number; error: string }>()

async function run($: EngineInterface, ...argv: string[]): Promise<boolean> {
  const { exitCode } = await $.process.run(argv)
  return exitCode === 0
}

async function git($: EngineInterface, ...args: string[]): Promise<string> {
  const { stdout } = await $.process.run(['git', ...args])
  return stdout.trim()
}

async function readJson<T>($: EngineInterface, path: string): Promise<T | undefined> {
  try {
    return JSON.parse((await $.fs.read(path)) as string) as T
  } catch {
    return undefined
  }
}

/** Write `path` in one step, so readers see the old or the new file, never half of one.
 *  `path`'s folder must exist: mv fails rather than recreate it. */
async function writeAtomic($: EngineInterface, path: string, text: string): Promise<boolean> {
  // The temp file sits in the state folder itself: $.fs.write creates missing folders, which
  // would recreate a lock folder another session just took away.
  const tmp = `${paths.dir}/tmp.${sessionId}`
  await $.fs.write(tmp, text)
  return run($, 'mv', '-f', tmp, path)
}

async function writeHeartbeat($: EngineInterface): Promise<boolean> {
  const heartbeat: Heartbeat = { sessionId, at: await $.clock.now(), version }
  return writeAtomic($, paths.heartbeat, JSON.stringify(heartbeat))
}

/** Whether this session holds the poller lease, taking it if it's free or stale. */
async function holdLease($: EngineInterface): Promise<boolean> {
  // mkdir succeeds for exactly one session.
  if (await run($, 'mkdir', paths.lock)) return writeHeartbeat($)

  const heartbeat = await readJson<Heartbeat>($, paths.heartbeat)
  if (heartbeat?.sessionId === sessionId) return writeHeartbeat($)
  // No heartbeat yet: another session just made the folder, or died right after.
  const at = heartbeat?.at ?? (await $.fs.stat(paths.lock).then(s => s.mtimeMs, () => 0))
  // A session still running an older version (started before an upgrade) hands over at once:
  // it would keep polling with the old code until it exits. Once the lease is someone
  // else's, an older poller stops at its next tick, as any poller does.
  const isOutdated = heartbeat !== undefined && isOlderVersion(heartbeat.version, version)
  if (!isOutdated && (await $.clock.now()) - at < LEASE_STALE_MS) return false

  // The poller died or is outdated. mv succeeds for exactly one session; the rest try again
  // next tick.
  const dead = `${paths.lock}.dead.${sessionId}`
  if (!(await run($, 'mv', paths.lock, dead))) return false
  await run($, 'rm', '-rf', dead)
  return (await run($, 'mkdir', paths.lock)) && writeHeartbeat($)
}

async function releaseLease($: EngineInterface): Promise<void> {
  const heartbeat = await readJson<Heartbeat>($, paths.heartbeat)
  if (heartbeat?.sessionId === sessionId) await run($, 'rm', '-rf', paths.lock)
}

/** Call a bbgithub MCP tool and parse its JSON reply. */
async function mcp<T>($: EngineInterface, tool: string, args: Record<string, unknown>): Promise<T> {
  const result = await $.mcp.call(config.mcpServer, tool, args)
  const text = result.content.map(block => block.text ?? '').join('')
  if (result.isError) throw new Error(`${tool} failed: ${text.slice(0, 300)}`)
  try {
    return JSON.parse(text) as T
  } catch {
    // A reply over one of Claude Code's size limits arrives as a note instead, isError unset:
    // - the MCP token limit (MAX_MCP_OUTPUT_TOKENS): "Error: result (N characters) exceeds
    //   maximum allowed tokens. Output has been saved to <file>. ..."
    // - the general size limit: "<persisted-output>Output too large (68.3KB). Full output
    //   saved to: <file> ..."
    // Both save the whole reply to <file>. Over a further limit only part is saved ("...persist
    // limit; only the first ... were saved to:", "...could not all be saved to..."), which
    // can't be parsed.
    if (/persist limit; only the first|could not all be saved/.test(text)) {
      throw new Error(`${tool} reply too large: Claude Code saved only part of it`)
    }
    const saved = /(?:Output has been saved to|Full output saved to:)\s+(\S+)/.exec(text)?.[1]?.replace(/\.$/, '')
    if (!saved) throw new Error(`${tool} returned non-JSON: ${text.slice(0, 200)}`)
    try {
      return JSON.parse((await $.fs.read(saved)) as string) as T
    } catch {
      throw new Error(`${tool} reply too large, and its saved copy (${saved}) isn't readable JSON`)
    }
  }
}

/** One PR's details and all its reviews/comments. Inline threads are read only when a review
 *  has arrived since `known` was recorded; `page.reviewThreads` is null when they weren't. */
async function readPr(
  $: EngineInterface,
  item: SearchItem,
  known: PullRequest | undefined,
): Promise<{ pr: PullRequest; page: ReviewsPage }> {
  const { owner, repo, number } = parsePrUrl(item.htmlUrl)
  const args = { owner, repo, pullNumber: number }
  const page: ReviewsPage = { reviews: [], comments: [], reviewThreads: null }
  let view: PrView | undefined
  for (let n = 1; n <= MAX_PAGES; n++) {
    const result = await mcp<{ view: PrView | null; reviews: ReviewsPage }>($, 'bbgithub-pr-read', {
      ...args,
      actions: n === 1 ? ['view', 'reviews'] : ['reviews'],
      includeComments: true,
      includeReviewComments: false,
      page: n,
      perPage: PER_PAGE,
    })
    view ??= result.view ?? undefined
    page.reviews.push(...result.reviews.reviews)
    page.comments.push(...result.reviews.comments)
    if (result.reviews.reviews.length < PER_PAGE && result.reviews.comments.length < PER_PAGE) break
  }
  if (!view) throw new Error(`bbgithub-pr-read returned no view for ${item.htmlUrl}`)

  const pr = { ...toPullRequest(view, item.updatedAt), lastReviewAt: lastReviewAt(page) }
  // Every inline comment (single, in a full review, or a reply) arrives in a review.
  const hasNewReview = known?.lastReviewAt === undefined || (pr.lastReviewAt ?? '') > known.lastReviewAt
  if (hasNewReview) {
    // The first 100 threads, whole: perPage doesn't apply to them.
    const result = await mcp<{ reviews: ReviewsPage }>($, 'bbgithub-pr-read', {
      ...args,
      actions: ['reviews'],
      includeComments: false,
      includeReviews: false,
      includeReviewComments: true,
    })
    page.reviewThreads = result.reviews.reviewThreads ?? []
  }
  return { pr, page }
}

/** Put the PR's unseen feedback in its inbox. The first time a PR is seen, its existing
 *  feedback is only marked seen; so are its existing inline comments the first time they're
 *  read (older versions didn't read them, and their backlog isn't new). */
async function fileFeedback($: EngineInterface, pr: PullRequest, items: Feedback[], hasThreads: boolean): Promise<void> {
  const h = await hash(pr.url)
  const seenDir = `${paths.dir}/seen/${h}`
  const inboxDir = `${paths.dir}/inbox/${h}`
  const threadsMarker = `${seenDir}/threads-read`
  const isNew = !(await $.fs.exists(seenDir))
  const isFirstThreadRead = !(await $.fs.exists(threadsMarker))
  await run($, 'mkdir', '-p', seenDir, inboxDir)
  for (const item of items) {
    const seenFile = `${seenDir}/${await hash(item.id)}`
    if (await $.fs.exists(seenFile)) continue
    const isBacklog = isNew || (item.location !== undefined && isFirstThreadRead)
    // Inbox first, then seen: a crash in between re-files the item (a duplicate prompt at
    // worst) instead of losing it.
    if (!isBacklog) await writeAtomic($, `${inboxDir}/${await hash(item.id)}.json`, JSON.stringify(item))
    await $.fs.write(seenFile, '')
  }
  if (hasThreads) await $.fs.write(threadsMarker, '')
}

/** As the poller: one search for my open PRs, then a read of each PR that changed. */
async function pollGitHub($: EngineInterface): Promise<void> {
  const search = await mcp<{ items: SearchItem[] }>($, 'bbgithub-search-issues-and-pull-requests', {
    q: 'is:pr is:open author:@me',
    perPage: PER_PAGE,
  })
  const known = (await readJson<Record<string, PullRequest>>($, paths.prs)) ?? {}
  const prs: Record<string, PullRequest> = {}
  const failures: string[] = []
  for (const item of search.items) {
    const pr = known[item.htmlUrl]
    // Reviews and comments bump updatedAt, so an unchanged PR has nothing new.
    if (pr?.updatedAt === item.updatedAt && pr.format === RECORD_FORMAT) {
      prs[item.htmlUrl] = pr
      continue
    }
    // A PR that failed recently: keep its old record and error until it's due for a retry, so
    // a PR that fails every time isn't re-read (and its big reply re-saved) every tick.
    const failed = failedPrs.get(item.htmlUrl)
    if (failed && (await $.clock.now()) < failed.retryAt) {
      failures.push(`${item.htmlUrl}: ${failed.error}`)
      if (pr) prs[item.htmlUrl] = pr
      continue
    }
    try {
      const read = await readPr($, item, pr)
      // The search was for my PRs, so the PR's author is me.
      await fileFeedback($, read.pr, feedbackOn(read.page, read.pr.author), read.page.reviewThreads !== null)
      prs[item.htmlUrl] = read.pr
      failedPrs.delete(item.htmlUrl)
    } catch (err) {
      // One bad PR mustn't stop the rest. Keeping its old record (old updatedAt) retries it
      // once RETRY_FAILED_PR_MS has passed.
      const error = `${err instanceof Error ? err.message : String(err)} (retrying every ${RETRY_FAILED_PR_MS / 60_000} min)`
      failedPrs.set(item.htmlUrl, { retryAt: (await $.clock.now()) + RETRY_FAILED_PR_MS, error })
      failures.push(`${item.htmlUrl}: ${error}`)
      if (pr) prs[item.htmlUrl] = pr
    }
  }
  // Closed/merged PRs: drop their undelivered feedback. seen/ stays, in case a PR reopens.
  for (const url of Object.keys(known)) {
    if (prs[url]) continue
    const h = await hash(url)
    await run($, 'rm', '-rf', `${paths.dir}/inbox/${h}`, `${paths.dir}/delivered/${h}`)
  }
  await writeAtomic($, paths.prs, JSON.stringify(prs))
  if (failures.length) throw new Error(`couldn't read ${failures.join('; ')}`)
}

/** Claim the inbox items for this session's PR and ask Claude to address them. */
async function deliver($: EngineInterface): Promise<void> {
  const branch = await git($, 'branch', '--show-current')
  status.branch = branch
  if (branch !== lastBranch) {
    // The first tick sees the branch the session started on; later changes are checkouts.
    onBranchSince = lastBranch === undefined ? startedAt : await $.clock.now()
    lastBranch = branch
  }
  const prs = Object.values((await readJson<Record<string, PullRequest>>($, paths.prs)) ?? {})
  const pr = branch ? findPr(prs, branch, remoteRepoNames(await git($, 'remote', '-v'))) : undefined
  status.prUrl = pr?.url
  if (!pr) return

  const h = await hash(pr.url)
  const inboxDir = `${paths.dir}/inbox/${h}`
  const deliveredDir = `${paths.dir}/delivered/${h}`
  const files = (await $.fs.list(inboxDir).catch(() => [])).filter(f => f.name.endsWith('.json'))
  if (!files.length) return
  await run($, 'mkdir', '-p', deliveredDir)
  const deliveredAt = new Date(await $.clock.now()).toISOString()
  const claimed: { file: string; item: Feedback }[] = []
  for (const { name } of files) {
    const file = `${deliveredDir}/${name}`
    // mv succeeds for exactly one session, so only one sends each item.
    if (!(await run($, 'mv', `${inboxDir}/${name}`, file))) continue
    const item = await readJson<Feedback>($, file)
    if (!item) continue
    // Posted before this session was on this branch: with onlyTriggerInRealTime, drop it.
    if (config.isRealTimeOnly && item.postedAt && Date.parse(item.postedAt) < onBranchSince) {
      const record: Delivered = { ...item, deliveredAt, sessionId, skipped: 'posted before this session was on this branch' }
      await writeAtomic($, file, JSON.stringify(record))
      continue
    }
    claimed.push({ file, item })
  }
  if (!claimed.length) return

  await $.prompt.submit({ text: buildMessage(pr, claimed.map(c => c.item), config.skill) })
  for (const { file, item } of claimed) {
    const record: Delivered = { ...item, deliveredAt, sessionId }
    await writeAtomic($, file, JSON.stringify(record))
  }
}

/** 👍 USAGE_COMMENT_URL as this user, once per machine (a marker file records it). GitHub keeps
 *  one 👍 per person, so a repeat is harmless. Failures are ignored and retried next session. */
async function reportUsage($: EngineInterface): Promise<void> {
  const marker = `${paths.dir}/usage-reported`
  if (await $.fs.exists(marker)) return
  const result = await $.mcp.call(config.mcpServer, 'bbgithub-dispatch', {
    toolName: 'bbgithub-comments-create-reaction',
    params: { commentUrl: USAGE_COMMENT_URL, content: '+1' },
  })
  if (!result.isError) await $.fs.write(marker, new Date(await $.clock.now()).toISOString())
}

async function tick($: EngineInterface): Promise<void> {
  // A slow bbgithub call can outlast the interval; skip rather than pile up.
  if (isTicking) return
  isTicking = true
  const errors: string[] = []
  const attempt = async (step: () => Promise<void>) => {
    try {
      await step()
    } catch (err) {
      errors.push(err instanceof Error ? err.message : String(err))
    }
  }
  try {
    status.lastTick = new Date(await $.clock.now()).toISOString()
    await attempt(async () => {
      status.isPoller = await holdLease($)
      if (status.isPoller) await pollGitHub($)
    })
    // Deliver even when polling failed: what's already in the inbox can still go out.
    await attempt(() => deliver($))
    // On the first tick, when MCP servers are connected. Not an error worth showing if it fails.
    if (!hasTriedUsageReport) {
      hasTriedUsageReport = true
      await reportUsage($).catch(() => undefined)
    }
    const error = errors.join('; ') || undefined
    // Log each distinct error once instead of on every tick.
    if (error && error !== status.error) $.ui.log(`${COMMAND}: ${error}`)
    if (!error && status.error) $.ui.log(`${COMMAND}: recovered`)
    status.error = error
  } finally {
    isTicking = false
  }
}

async function describe($: EngineInterface): Promise<string> {
  const heartbeat = await readJson<Heartbeat>($, paths.heartbeat)
  const poller = status.isPoller
    ? 'this session'
    : heartbeat
      ? `session ${heartbeat.sessionId} (v${heartbeat.version ?? '<0.2.4'}), heartbeat ${Math.round(((await $.clock.now()) - heartbeat.at) / 1000)}s ago`
      : 'none'
  const lines = [
    `Branch: ${status.branch || '(none)'}`,
    `PR: ${status.prUrl ?? 'no open PR of yours for this branch'}`,
    `Poller: ${poller}`,
    `Last tick: ${status.lastTick ?? 'not yet'}, every ${config.intervalMs / 1000}s`,
    `Skill: ${config.skill}`,
    `Only real-time feedback: ${config.isRealTimeOnly ? `yes, since ${new Date(onBranchSince).toISOString()}` : 'no'}`,
    `Plugin version: ${version}`,
    `State: ${paths.dir}`,
  ]
  if (status.error) lines.push(`Error: ${status.error}`)
  if (status.prUrl) {
    const h = await hash(status.prUrl)
    const waiting = await $.fs.list(`${paths.dir}/inbox/${h}`).catch(() => [])
    const delivered = await $.fs.list(`${paths.dir}/delivered/${h}`).catch(() => [])
    const recent = [...delivered].sort((a, b) => a.mtimeMs - b.mtimeMs).slice(-10)
    lines.push('', `Waiting in inbox: ${waiting.length}`, 'Recently delivered:')
    if (!recent.length) lines.push('(none)')
    for (const { name } of recent) {
      const item = await readJson<Delivered>($, `${paths.dir}/delivered/${h}/${name}`)
      const outcome = item?.skipped ? `skipped: ${item.skipped}` : 'sent'
      if (item) lines.push(`${item.deliveredAt ?? '?'}  ${item.kind} by ${item.author}  ${outcome}  ${item.id}`)
    }
  }
  return lines.join('\n')
}

export const register: Register = (on, options) => {
  // An option saved as an empty string counts as unset.
  const option = (key: string) => String(options[key] ?? '').trim() || undefined
  config.skill = skillName(option('skill') ?? config.skill)
  config.mcpServer = option('mcpServer') ?? config.mcpServer
  config.intervalMs = Math.max(5, Number(option('intervalSeconds') ?? 10)) * 1000
  config.isRealTimeOnly = option('onlyTriggerInRealTime') === 'true'

  on('session.start', async ($, e, next) => {
    const home = await $.env.get('HOME')
    paths.dir = `${home}/${STATE_DIR}`
    paths.lock = `${paths.dir}/poller.lock`
    paths.heartbeat = `${paths.lock}/heartbeat`
    paths.prs = `${paths.dir}/prs.json`
    sessionId = await $.session.id()
    startedAt = await $.clock.now()
    const manifest = await readJson<{ version?: string }>($, `${$.plugin.root}/.claude-plugin/plugin.json`)
    version = manifest?.version ?? '0'
    await run($, 'mkdir', '-p', paths.dir)
    await $.command.register({
      name: COMMAND,
      description: "Show the GitHub PR feedback watcher's status for this branch",
    })
    // No tick right away: MCP servers are still connecting when the session starts.
    $.clock.every(config.intervalMs, () => void tick($))

    return next(e)
  })

  on('session.end', async ($, e, next) => {
    // Hand the lease over now instead of after LEASE_STALE_MS.
    await releaseLease($).catch(() => undefined)
    return next(e)
  })

  on('command.run', { command: COMMAND }, async $ => ({ text: await describe($) }))
}
