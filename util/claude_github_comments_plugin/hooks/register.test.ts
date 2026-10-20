import { expect, mock, test } from 'claude-code/testing'
import type { Engine, MockClock } from 'claude-code/testing'
import type { On } from 'claude-code'

import { hash, isOlderVersion } from './feedback'

const PR_URL = 'https://bbgithub.dev.bloomberg.com/me/repo/pull/7'
const BROKEN_PR_URL = 'https://bbgithub.dev.bloomberg.com/me/other/pull/8'
const DIR = '/home/me/.local/state/pr-feedback-watcher'
const LOCK = `${DIR}/poller.lock`
const VERSION = '0.2.4'

type Node = { htmlUrl: string; state?: string; body: string; user: { login: string }; submittedAt?: string; createdAt?: string }

/** What bbgithub holds; bump `updatedAt` when adding feedback, as GitHub does. */
type Thread = { path: string; line: number | null; comments: { htmlUrl: string; body: string; author: { login: string }; createdAt?: string }[] }
type GitHub = {
  updatedAt: string
  reviews: Node[]
  comments: Node[]
  threads?: Thread[]
  // Answer pr-read the way Claude Code does when a reply is over one of its size limits:
  // 'tokens' (MCP token limit), 'bytes' (general size limit), or 'partial' (only part saved).
  oversized?: 'tokens' | 'bytes' | 'partial'
  // Also list a second open PR (#8) whose pr-read returns non-JSON text.
  hasBrokenPr?: boolean
}

/** A folder tree in memory: a path maps to file text, or to null for a folder. */
class FakeFs {
  nodes = new Map<string, string | null>([['/', null]])
  // Paths `mv` should fail on, standing for another session moving them first.
  stolen = new Set<string>()

  parent(path: string): string {
    return path.slice(0, path.lastIndexOf('/')) || '/'
  }
  mkdirs(path: string): void {
    if (path === '/' || this.nodes.has(path)) return
    this.mkdirs(this.parent(path))
    this.nodes.set(path, null)
  }
  write(path: string, text: string): void {
    this.mkdirs(this.parent(path))
    this.nodes.set(path, text)
  }
  under(path: string): string[] {
    return [...this.nodes.keys()].filter(p => p === path || p.startsWith(`${path}/`))
  }
  /** Run mkdir, mv or rm as the plugin does; returns the exit code. */
  run(argv: readonly string[]): number {
    const [cmd, ...rest] = argv
    const args = rest.filter(a => !a.startsWith('-'))
    if (cmd === 'mkdir') {
      if (rest.includes('-p')) return args.forEach(p => this.mkdirs(p)), 0
      const [path = ''] = args
      if (this.nodes.has(path) || !this.nodes.has(this.parent(path))) return 1
      this.nodes.set(path, null)
      return 0
    }
    if (cmd === 'mv') {
      const [from = '', to = ''] = args
      if (this.stolen.has(from) || !this.nodes.has(from) || !this.nodes.has(this.parent(to))) return 1
      for (const p of this.under(from)) {
        const value = this.nodes.get(p)!
        this.nodes.delete(p)
        this.nodes.set(to + p.slice(from.length), value)
      }
      return 0
    }
    if (cmd === 'rm') return args.forEach(path => this.under(path).forEach(p => this.nodes.delete(p))), 0
    throw new Error(`unexpected command ${argv.join(' ')}`)
  }
}

type World = { fs: FakeFs; prompts: string[]; mcpCalls: string[]; clock: MockClock; calls: number; ticks: number; branch: string; threadReads: number; reactions: unknown[]; prReads: number[] }

/** Stand in for git, the filesystem, bbgithub and the session. */
function fakeWorld(on: On, github: GitHub, branch = 'feature'): World {
  const fs = new FakeFs()
  const world: World = { fs, prompts: [], mcpCalls: [], clock: mock.clock(on, { now: 1_000_000 }), calls: 0, ticks: 0, branch, threadReads: 0, reactions: [], prReads: [] }
  // Counts every call the plugin makes, so step() can tell when a tick has finished.
  const counted: On = ((event: string, ...rest: unknown[]) => {
    const hook = rest.pop() as (...args: unknown[]) => unknown
    return (on as (...args: unknown[]) => unknown)(event, ...rest, (...args: unknown[]) => (world.calls++, hook(...args)))
  }) as On
  const value = <T>(v: T) => ({ value: v })
  const ran = (exitCode: number, stdout = '') =>
    value({ exitCode, stdout, stderr: '', isStdoutTruncated: false, isStderrTruncated: false })
  mock.env(on, { HOME: '/home/me' })
  counted('session.start', async (_$, e) => ({ cwd: e.cwd }))
  counted('session.end', async (_$, e) => ({ sessionId: e.sessionId }))
  counted('session.id', async () => value('session-a'))
  counted('command.register', async (_$, e) => value({ command: e.name }))
  counted('ui.log', async () => value(undefined))
  counted('prompt.submit', async (_$, e) => {
    world.prompts.push(e.text)
    return { text: e.text }
  })
  counted('process.run', async (_$, e) => {
    const cmd = e.argv.slice(0, 2).join(' ')
    // Every tick reads the branch once.
    if (cmd === 'git branch') return world.ticks++, ran(0, `${world.branch}\n`)
    if (cmd === 'git remote') return ran(0, 'origin\tgit@bbgithub.dev.bloomberg.com:me/repo.git (fetch)\n')
    return ran(fs.run(e.argv))
  })
  counted('fs.read', async (_$, e) => {
    if (e.path.endsWith('/.claude-plugin/plugin.json')) return value(JSON.stringify({ version: VERSION }))
    const text = fs.nodes.get(e.path)
    if (typeof text !== 'string') throw new Error(`ENOENT ${e.path}`)
    return value(text)
  })
  counted('fs.write', async (_$, e) => (fs.write(e.path, e.text), value(undefined)))
  counted('fs.exists', async (_$, e) => value(fs.nodes.has(e.path)))
  counted('fs.stat', async (_$, e) => {
    if (!fs.nodes.has(e.path)) throw new Error(`ENOENT ${e.path}`)
    return value({ kind: 'dir' as const, size: 0, mtimeMs: world.clock.now(), isLink: false })
  })
  counted('fs.list', async (_$, e) => {
    if (fs.nodes.get(e.path) !== null) throw new Error(`ENOENT ${e.path}`)
    const names = [...fs.nodes.keys()].filter(p => fs.parent(p) === e.path && p !== '/')
    return value(names.map(p => ({ name: p.slice(e.path.length + 1), kind: 'file' as const, size: 0, mtimeMs: 0, isLink: false })))
  })
  counted('mcp.call', async (_$, e) => {
    if (e.server !== 'bbgithub') throw new Error(`no MCP server named ${e.server}`)
    if (e.tool === 'bbgithub-dispatch') {
      world.reactions.push(e.args)
      return value({ content: [{ type: 'text', text: '{"output":{"reaction":"+1"}}' }], isError: false })
    }
    world.mcpCalls.push(e.tool)
    if (e.tool === 'bbgithub-pr-read') world.prReads.push(Number(e.args.pullNumber))
    const replyText = (text: string) => value({ content: [{ type: 'text', text }], isError: false })
    const reply = (data: unknown) => replyText(JSON.stringify(data))
    if (e.tool === 'bbgithub-search-issues-and-pull-requests') {
      const broken = github.hasBrokenPr ? [{ htmlUrl: BROKEN_PR_URL, updatedAt: github.updatedAt }] : []
      return reply({ items: [...broken, { htmlUrl: PR_URL, updatedAt: github.updatedAt }] })
    }
    if (e.tool === 'bbgithub-pr-read' && e.args.pullNumber === 8) return replyText('Error: something went wrong')
    if (e.tool === 'bbgithub-pr-read') {
      const view = {
        htmlUrl: PR_URL, number: 7, title: 'My PR', updatedAt: github.updatedAt, user: { login: 'me' },
        head: { ref: 'feature', repo: { name: 'repo' } },
        base: { repo: { name: 'repo', owner: { login: 'me' } } },
      }
      const actions = e.args.actions as string[]
      if (e.args.includeReviewComments) world.threadReads++
      const threads = e.args.includeReviewComments ? github.threads ?? [] : null
      const data = {
        view: actions.includes('view') ? view : null,
        reviews: { reviews: github.reviews, comments: github.comments, reviewThreads: threads },
      }
      if (!github.oversized) return reply(data)
      const saved = `/home/me/.claude/projects/x/tool-results/mcp-bbgithub-pr-read-${world.calls}.txt`
      const text = JSON.stringify(data)
      if (github.oversized === 'partial') {
        fs.write(saved, text.slice(0, 50))
        return replyText(`<persisted-output>Output exceeded the 64KB persist limit; only the first 64KB were saved to: ${saved}\n</persisted-output>`)
      }
      fs.write(saved, text)
      if (github.oversized === 'bytes') {
        return replyText(`<persisted-output>Output too large (68.3KB). Full output saved to: ${saved}\n\nPreview (first 2KB):\n${text.slice(0, 100)}\n</persisted-output>`)
      }
      return replyText(
        `Error: result (148,576 characters) exceeds maximum allowed tokens. Output has been saved to ${saved}.\n` +
          'Format: JSON with schema: {...}\nUse jq to make structured queries (find a value, filter by field).',
      )
    }
    throw new Error(`unexpected MCP call ${e.tool}`)
  })
  return world
}

/** Move the clock `ms` (whole 10s intervals) on, then wait until each tick due has started and
 *  the plugin has stopped making calls: the clock's settle alone can return while a tick is
 *  still starting or running on a busy machine. */
async function step(world: World, ms: number): Promise<void> {
  const ticks = world.ticks + ms / 10_000
  await world.clock.advance(ms)
  for (let quiet = 0, rounds = 0; world.ticks < ticks || quiet < 5; rounds++) {
    if (rounds > 5_000) throw new Error(`timed out waiting for tick ${ticks} (at ${world.ticks})`)
    const before = world.calls
    await world.clock.settle()
    quiet = world.calls === before ? quiet + 1 : 0
  }
}

async function start($: Engine, world: World): Promise<void> {
  await $.session.start({ cwd: '/repo', surface: 'terminal', isInteractive: true })
  // The first tick comes one interval after start.
  await step(world, 10_000)
}

function comment(n: number, login: string, body = 'nit'): Node {
  return { htmlUrl: `${PR_URL}#issuecomment-${n}`, body, user: { login } }
}

test('seeds existing feedback, then sends only new feedback', async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [{ ...comment(1, 'bob', 'old'), state: 'COMMENTED' }], comments: [] }
  const world = fakeWorld(on, github)

  await start($, world)
  expect(world.prompts).toEqual([])

  github.comments.push(comment(2, 'alice'))
  github.updatedAt = 't1'
  await step(world, 10_000)
  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Please use the pr-feedback-watcher:address-pr-feedback skill')
  expect(world.prompts[0]).toContain('Feedback from alice.')

  await step(world, 10_000)
  expect(world.prompts.length).toBe(1)
})

test('makes one request per tick while no PR changes', async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [] })

  await start($, world)
  world.mcpCalls.length = 0
  for (let i = 0; i < 3; i++) await step(world, 10_000)
  expect(world.mcpCalls).toEqual(Array(3).fill('bbgithub-search-issues-and-pull-requests'))
})

test('ignores my own comments unless they start with /claude or @claude', async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [] }
  const world = fakeWorld(on, github)

  await start($, world)
  github.comments.push(comment(1, 'me', 'thanks!'), comment(2, 'me', '@claude rename this to isDone'))
  github.reviews.push({ ...comment(3, 'bob', 'draft'), state: 'PENDING' })
  github.updatedAt = 't1'
  await step(world, 10_000)

  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Please use the pr-feedback-watcher:address-pr-feedback skill')
  expect(world.prompts[0]).toContain(`Instruction from the PR author (${PR_URL}#issuecomment-2):\nrename this to isDone`)
  expect(world.prompts[0]).not.toContain('Feedback from')
})

test("doesn't poll while another session's lease is fresh, and takes over once it's stale", async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [] })
  world.fs.mkdirs(LOCK)
  world.fs.write(`${LOCK}/heartbeat`, JSON.stringify({ sessionId: 'session-b', at: 1_000_000, version: VERSION }))

  await start($, world)
  await step(world, 10_000)
  expect(world.mcpCalls).toEqual([])

  // session-b stopped renewing; 30s after its last heartbeat, session-a takes over.
  await step(world, 10_000)
  expect(world.mcpCalls).toContain('bbgithub-search-issues-and-pull-requests')
  expect(JSON.parse(world.fs.nodes.get(`${LOCK}/heartbeat`)!).sessionId).toBe('session-a')
})

test("delivers inbox items filed by another session's poller", async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [] })
  const h = await hash(PR_URL)
  const pr = {
    url: PR_URL, title: 'My PR', owner: 'me', repo: 'repo', number: 7, author: 'me',
    headRefName: 'feature', repoNames: ['repo'], updatedAt: 't0', format: 2,
  }
  world.fs.write(`${DIR}/prs.json`, JSON.stringify({ [PR_URL]: pr }))
  // Posted before this session started; sent anyway, as onlyTriggerInRealTime is off by default.
  world.fs.write(`${DIR}/inbox/${h}/a.json`, JSON.stringify({ id: 'x', kind: 'comment', author: 'alice', postedAt: new Date(0).toISOString() }))
  world.fs.write(`${DIR}/inbox/${h}/b.json`, JSON.stringify({ id: 'y', kind: 'comment', author: 'carol' }))
  // Another session on this branch claims b.json first.
  world.fs.stolen.add(`${DIR}/inbox/${h}/b.json`)
  world.fs.mkdirs(LOCK)
  world.fs.write(`${LOCK}/heartbeat`, JSON.stringify({ sessionId: 'session-b', at: 1_000_000, version: VERSION }))

  await start($, world)
  expect(world.mcpCalls).toEqual([])
  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Feedback from alice.')
  expect(world.prompts[0]).not.toContain('carol')
  expect(world.fs.nodes.has(`${DIR}/inbox/${h}/a.json`)).toBe(false)
  expect(JSON.parse(world.fs.nodes.get(`${DIR}/delivered/${h}/a.json`)!).sessionId).toBe('session-a')
})

test('releases the lease when the session ends', async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [] })

  await start($, world)
  expect(world.fs.nodes.has(LOCK)).toBe(true)
  await $.session.end({ reason: 'prompt_input_exit', sessionId: 'session-a', resume: { sessionId: 'session-a' } } as never)
  expect(world.fs.nodes.has(LOCK)).toBe(false)
})

test('/pr-watch reports the PR and the poller', async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [] })

  await start($, world)
  const { text } = await $.command.run({
    command: 'pr-watch', args: '', origin: { kind: 'composer' },
    presentation: { isFullscreen: false, columns: 120 },
  })
  expect(text).toContain(`PR: ${PR_URL}`)
  expect(text).toContain('Poller: this session')
})

test('accepts the skill option as a folder path', { options: { skill: '~/.claude/skills/my-skill/' } }, async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [] }
  const world = fakeWorld(on, github)

  await start($, world)
  github.comments.push(comment(1, 'alice'))
  github.updatedAt = 't1'
  await step(world, 10_000)

  expect(world.prompts[0]).toContain('Please use the my-skill skill')
})

test('treats options saved as empty strings as unset', { options: { skill: '', mcpServer: '' } }, async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [] }
  const world = fakeWorld(on, github)

  await start($, world)
  github.comments.push(comment(1, 'alice'))
  github.updatedAt = 't1'
  await step(world, 10_000)

  expect(world.prompts[0]).toContain('Please use the pr-feedback-watcher:address-pr-feedback skill')
  // fakeWorld's bbgithub answers only on the default server name, so this also checks mcpServer.
})

test('relays my inline /claude comments with where they are', async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [], threads: [] }
  const world = fakeWorld(on, github)

  await start($, world)
  // GitHub records an inline comment as an empty review plus a thread comment.
  github.reviews.push({ htmlUrl: `${PR_URL}#pullrequestreview-9`, state: 'COMMENTED', body: '', user: { login: 'me' } })
  github.threads!.push({
    path: 'README.md',
    line: 44,
    comments: [{ htmlUrl: `${PR_URL}#discussion_r1`, body: '/claude can you resolve this comment?', author: { login: 'me' } }],
  })
  github.updatedAt = 't1'
  await step(world, 10_000)

  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain(
    `Instruction from the PR author on README.md:44 (${PR_URL}#discussion_r1):\ncan you resolve this comment?`,
  )
})

test('after an upgrade, re-reads each PR once and seeds old inline comments without sending them', async ($, on) => {
  const github: GitHub = {
    updatedAt: 't0',
    reviews: [],
    comments: [],
    threads: [{ path: 'a.ts', line: 1, comments: [{ htmlUrl: `${PR_URL}#discussion_r1`, body: 'old nit', author: { login: 'bob' } }] }],
  }
  const world = fakeWorld(on, github)
  const h = await hash(PR_URL)
  // State left by a version that didn't read inline comments: PR known, no format, no threads-read.
  const old = { url: PR_URL, title: 'My PR', owner: 'me', repo: 'repo', number: 7, author: 'me', headRefName: 'feature', repoNames: ['repo'], updatedAt: 't0' }
  world.fs.write(`${DIR}/prs.json`, JSON.stringify({ [PR_URL]: old }))
  world.fs.mkdirs(`${DIR}/seen/${h}`)

  await start($, world)
  expect(world.mcpCalls).toContain('bbgithub-pr-read')
  expect(world.prompts).toEqual([])

  github.threads![0]!.comments.push({ htmlUrl: `${PR_URL}#discussion_r2`, body: 'new nit', author: { login: 'carol' } })
  github.updatedAt = 't1'
  await step(world, 10_000)
  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Feedback from carol.')
  expect(world.prompts[0]).not.toContain('bob')
})

test('takes over at once from a poller running an older version', async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [] })
  world.fs.mkdirs(LOCK)
  // A fresh heartbeat from a session started before an upgrade (versions before 0.2.4 write none).
  world.fs.write(`${LOCK}/heartbeat`, JSON.stringify({ sessionId: 'session-b', at: 1_000_000 + 10_000 }))

  await start($, world)
  expect(world.mcpCalls).toContain('bbgithub-search-issues-and-pull-requests')
  expect(JSON.parse(world.fs.nodes.get(`${LOCK}/heartbeat`)!)).toEqual({ sessionId: 'session-a', at: 1_010_000, version: VERSION })
})

test('compares versions numerically', () => {
  expect(isOlderVersion('0.2.3', '0.2.4')).toBe(true)
  expect(isOlderVersion('0.9.0', '0.10.0')).toBe(true)
  expect(isOlderVersion('0.2.4', '0.2.4')).toBe(false)
  expect(isOlderVersion('1.0.0', '0.9.9')).toBe(false)
  expect(isOlderVersion(undefined, '0.2.4')).toBe(true)
})

test('with onlyTriggerInRealTime, skips feedback posted before the session started', { options: { onlyTriggerInRealTime: true } }, async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [] }
  const world = fakeWorld(on, github)
  const h = await hash(PR_URL)
  const pr = {
    url: PR_URL, title: 'My PR', owner: 'me', repo: 'repo', number: 7, author: 'me',
    headRefName: 'feature', repoNames: ['repo'], updatedAt: 't0', format: 2,
  }
  world.fs.write(`${DIR}/seen/${h}/threads-read`, '')
  world.fs.write(`${DIR}/prs.json`, JSON.stringify({ [PR_URL]: pr }))
  // Filed while no session was on this branch.
  world.fs.write(`${DIR}/inbox/${h}/old.json`, JSON.stringify({ id: 'x', kind: 'comment', author: 'bob', postedAt: new Date(999_000).toISOString() }))

  await start($, world)
  expect(world.prompts).toEqual([])
  const skipped = JSON.parse(world.fs.nodes.get(`${DIR}/delivered/${h}/old.json`)!)
  expect(skipped.skipped).toBe('posted before this session was on this branch')

  github.comments.push({ ...comment(1, 'alice'), createdAt: new Date(world.clock.now()).toISOString() } as Node)
  github.updatedAt = 't1'
  await step(world, 10_000)
  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Feedback from alice.')
  expect(world.prompts[0]).not.toContain('bob')
})

test('with onlyTriggerInRealTime, skips feedback posted before a checkout onto the branch', { options: { onlyTriggerInRealTime: true } }, async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [] }
  const world = fakeWorld(on, github, 'other-branch')
  const h = await hash(PR_URL)

  await start($, world)
  // While this session is on another branch, a comment lands on the PR for 'feature'.
  github.comments.push({ ...comment(1, 'bob'), createdAt: new Date(world.clock.now()).toISOString() } as Node)
  github.updatedAt = 't1'
  await step(world, 10_000)
  expect(world.fs.nodes.has(`${DIR}/inbox/${h}/${await hash(`${PR_URL}#issuecomment-1`)}.json`)).toBe(true)

  // Check out 'feature': the comment predates the session's arrival on it, so it's skipped.
  await step(world, 10_000)
  world.branch = 'feature'
  await step(world, 10_000)
  expect(world.prompts).toEqual([])

  github.comments.push({ ...comment(2, 'alice'), createdAt: new Date(world.clock.now()).toISOString() } as Node)
  github.updatedAt = 't2'
  await step(world, 10_000)
  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Feedback from alice.')
  expect(world.prompts[0]).not.toContain('bob')
})

test('reads replies over the MCP output limit from the file Claude Code saved them to', async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [], oversized: 'tokens' }
  const world = fakeWorld(on, github)

  await start($, world)
  github.comments.push(comment(1, 'alice'))
  github.updatedAt = 't1'
  await step(world, 10_000)

  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Feedback from alice.')
})

test("a PR that can't be read doesn't stop the others", async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [], hasBrokenPr: true }
  const world = fakeWorld(on, github)

  await start($, world)
  github.comments.push(comment(1, 'alice'))
  github.updatedAt = 't1'
  await step(world, 10_000)

  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Feedback from alice.')
  const { text } = await $.command.run({
    command: 'pr-watch', args: '', origin: { kind: 'composer' },
    presentation: { isFullscreen: false, columns: 120 },
  })
  expect(text).toContain(`PR: ${PR_URL}`)
  expect(text).toContain(`Error: couldn't read ${BROKEN_PR_URL}: bbgithub-pr-read returned non-JSON: Error: something went wrong`)
})

const iso = (ms: number) => new Date(ms).toISOString()

/** A review and the inline comment that went out in it, drafted `draftedMs` earlier. */
function inlineReview(github: GitHub, n: number, login: string, body: string, submittedMs: number, draftedMs = 0): void {
  github.reviews.push({ htmlUrl: `${PR_URL}#pullrequestreview-${n}`, state: 'COMMENTED', body: '', user: { login }, submittedAt: iso(submittedMs) })
  github.threads!.push({
    path: 'a.ts',
    line: n,
    comments: [{ htmlUrl: `${PR_URL}#discussion_r${n}`, body, author: { login }, createdAt: iso(submittedMs - draftedMs) }],
  })
}

test('reads inline threads only when a new review has arrived', async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [], threads: [] }
  const world = fakeWorld(on, github)
  inlineReview(github, 1, 'bob', 'old nit', 900_000)

  await start($, world)
  expect(world.threadReads).toBe(1)

  // A top-level comment: no new review, so no thread read.
  github.comments.push(comment(2, 'alice'))
  github.updatedAt = 't1'
  await step(world, 10_000)
  expect(world.threadReads).toBe(1)
  expect(world.prompts.length).toBe(1)

  // A one-off inline comment arrives in a new review.
  inlineReview(github, 3, 'carol', 'new nit', world.clock.now())
  github.updatedAt = 't2'
  await step(world, 10_000)
  expect(world.threadReads).toBe(2)
  expect(world.prompts.length).toBe(2)
  expect(world.prompts[1]).toContain('Feedback from carol.')
})

test('with onlyTriggerInRealTime, times an inline comment by its review, not its draft', { options: { onlyTriggerInRealTime: true } }, async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [], threads: [] }
  const world = fakeWorld(on, github)

  await start($, world)
  // My own inline /claude comment (my review itself isn't feedback, so only the comment's time
  // counts): drafted a minute before this session started, submitted after.
  inlineReview(github, 1, 'me', '/claude fix this', world.clock.now(), 70_000)
  github.updatedAt = 't1'
  await step(world, 10_000)

  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('fix this')
})

test('reports usage once per machine with a 👍 on the install-tracker comment', async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [] })

  await start($, world)
  await step(world, 10_000)
  expect(world.reactions).toEqual([
    {
      toolName: 'bbgithub-comments-create-reaction',
      params: {
        commentUrl: 'https://bbgithub.dev.bloomberg.com/nrubin19/claude_github_comments_plugin/issues/1#issuecomment-15552086',
        content: '+1',
      },
    },
  ])
  expect(world.fs.nodes.has(`${DIR}/usage-reported`)).toBe(true)
})

test("doesn't report usage when it was already reported on this machine", async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [] })
  world.fs.write(`${DIR}/usage-reported`, 'earlier')

  await start($, world)
  expect(world.reactions).toEqual([])
})

test("reads replies over Claude Code's general size limit from the file it saved them to", async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [], oversized: 'bytes' }
  const world = fakeWorld(on, github)

  await start($, world)
  github.comments.push(comment(1, 'alice'))
  github.updatedAt = 't1'
  await step(world, 10_000)

  expect(world.prompts.length).toBe(1)
  expect(world.prompts[0]).toContain('Feedback from alice.')
})

test('says so when Claude Code saved only part of a reply', async ($, on) => {
  const world = fakeWorld(on, { updatedAt: 't0', reviews: [], comments: [], oversized: 'partial' })

  await start($, world)
  const { text } = await $.command.run({
    command: 'pr-watch', args: '', origin: { kind: 'composer' },
    presentation: { isFullscreen: false, columns: 120 },
  })
  expect(text).toContain(`couldn't read ${PR_URL}: bbgithub-pr-read reply too large: Claude Code saved only part of it`)
})

test('retries a PR that failed only every 5 minutes, showing its error meanwhile', async ($, on) => {
  const github: GitHub = { updatedAt: 't0', reviews: [], comments: [], hasBrokenPr: true }
  const world = fakeWorld(on, github)
  const brokenReads = () => world.prReads.filter(n => n === 8).length

  await start($, world)
  expect(brokenReads()).toBe(1)
  for (let i = 0; i < 6; i++) await step(world, 10_000)
  expect(brokenReads()).toBe(1)
  const { text } = await $.command.run({
    command: 'pr-watch', args: '', origin: { kind: 'composer' },
    presentation: { isFullscreen: false, columns: 120 },
  })
  expect(text).toContain(`couldn't read ${BROKEN_PR_URL}`)

  // 5 minutes after the failure (start's tick was at 10s; we're at 70s), it's tried again.
  for (let i = 0; i < 24; i++) await step(world, 10_000)
  expect(brokenReads()).toBe(2)
})
