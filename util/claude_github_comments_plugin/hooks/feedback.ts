// Pure logic, kept apart from register.ts so tests can call it directly.

// My own comments are ignored unless they start with one of these, e.g. "/claude add tests".
// Claude posts as me, so the skill must never start a comment this way, or it would loop.
const COMMAND_PREFIX = /^\s*[/@]claude\b/i

type User = { login: string } | null

/** A row of bbgithub-search-issues-and-pull-requests. */
export type SearchItem = { htmlUrl: string; updatedAt: string }

/** The `view` section of bbgithub-pr-read. */
export type PrView = {
  htmlUrl: string
  number: number
  title: string
  updatedAt: string
  user: User
  head: { ref: string; repo: { name: string } | null }
  base: { repo: { name: string; owner: { login: string } } }
}

/** One of my open PRs, as the poller records it in prs.json. */
export type PullRequest = {
  url: string
  title: string
  owner: string
  repo: string
  number: number
  author: string
  headRefName: string
  // Repo names a local checkout of the PR may have: the base repo's and, for a fork, the head repo's.
  repoNames: string[]
  // From the search; when it changes, the poller re-reads the PR.
  updatedAt: string
  // RECORD_FORMAT when read; an older record is re-read once (see RECORD_FORMAT).
  format?: number
  // The newest review's submittedAt. Every inline comment arrives in a review, so inline
  // threads (big: each carries a diff hunk) are only read when this moves.
  lastReviewAt?: string
}

// Bump when a newer plugin reads more of a PR than older ones recorded, so every PR is
// re-read once after an upgrade. 2: inline review comments.
export const RECORD_FORMAT = 2

/** The `reviews` section of bbgithub-pr-read with includeComments. */
export type ReviewsPage = {
  reviews: { htmlUrl: string; state: string; body: string | null; user: User; submittedAt?: string }[]
  comments: { htmlUrl: string; body: string | null; user: User; createdAt?: string }[]
  // Inline comments on the code, grouped by thread. null when not asked for.
  reviewThreads?: ReviewThread[] | null
}

export type ReviewThread = {
  path: string
  line: number | null
  comments: { htmlUrl: string; body: string | null; author: User; createdAt?: string }[]
}

export type Feedback = {
  // The comment's or review's URL, which is unique.
  id: string
  // "command" is my own /claude or @claude comment.
  kind: 'review' | 'comment' | 'command'
  author: string
  instruction?: string
  // For an inline comment: where in the code, e.g. "README.md:44".
  location?: string
  // When it was posted (ISO 8601), per GitHub.
  postedAt?: string
}

/** `owner`, `repo` and `number` from a PR's URL. */
export function parsePrUrl(url: string): { owner: string; repo: string; number: number } {
  const [, owner = '', repo = '', , number = ''] = new URL(url).pathname.split('/')
  return { owner, repo, number: Number(number) }
}

export function toPullRequest(view: PrView, updatedAt: string): PullRequest {
  const base = view.base.repo
  return {
    url: view.htmlUrl,
    title: view.title,
    owner: base.owner.login,
    repo: base.name,
    number: view.number,
    author: view.user?.login ?? '',
    headRefName: view.head.ref,
    repoNames: [...new Set([base.name, view.head.repo?.name ?? base.name])],
    updatedAt,
    format: RECORD_FORMAT,
  }
}

/** The PR whose head is `branch` in a repo named one of `repoNames`. */
export function findPr(prs: PullRequest[], branch: string, repoNames: Set<string>): PullRequest | undefined {
  // Match on repo name only, not owner: repos get transferred/renamed (GitHub redirects
  // the old URL, so local remotes keep the old owner), and forks have a different owner.
  return prs.find(pr => pr.headRefName === branch && pr.repoNames.some(name => repoNames.has(name)))
}

/** A short hex digest of `text`, used to name files after URLs. */
export async function hash(text: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text))
  return [...new Uint8Array(digest).slice(0, 8)].map(b => b.toString(16).padStart(2, '0')).join('')
}

/** Repo names from `git remote -v` output. */
export function remoteRepoNames(remoteOutput: string): Set<string> {
  const names = new Set<string>()
  for (const line of remoteOutput.split('\n')) {
    const url = line.split(/\s+/)[1]
    if (url) names.add(url.replace(/\.git$/, '').split(/[/:]/).pop()!)
  }
  return names
}

/** Submitted reviews and comments, minus mine (`me`) unless they're a command. */
export function feedbackOn(page: ReviewsPage, me: string): Feedback[] {
  const items: Feedback[] = []
  const groups = [
    ['review', page.reviews],
    ['comment', page.comments],
  ] as const
  for (const [kind, nodes] of groups) {
    for (const node of nodes) {
      if ('state' in node && node.state === 'PENDING') continue
      const postedAt = 'submittedAt' in node ? node.submittedAt : 'createdAt' in node ? node.createdAt : undefined
      const item = toFeedback(node.htmlUrl, kind, node.user?.login, node.body, me)
      if (item) items.push({ ...item, postedAt })
    }
  }
  for (const thread of page.reviewThreads ?? []) {
    const location = thread.line === null ? thread.path : `${thread.path}:${thread.line}`
    for (const node of thread.comments) {
      const item = toFeedback(node.htmlUrl, 'comment', node.author?.login, node.body, me)
      if (item) items.push({ ...item, location, postedAt: submittedAt(page, node.author?.login, node.createdAt) })
    }
  }
  return items
}

/** When an inline comment was posted: its createdAt is when it was drafted, so use the
 *  submittedAt of the review it went out in, the author's first review at or after that. */
function submittedAt(page: ReviewsPage, login: string | undefined, createdAt: string | undefined): string | undefined {
  if (!createdAt) return undefined
  const times = page.reviews
    .filter(r => r.user?.login === login && r.submittedAt && r.submittedAt >= createdAt)
    .map(r => r.submittedAt!)
    .sort()
  return times[0] ?? createdAt
}

/** The newest review's submittedAt, or undefined when there are none. */
export function lastReviewAt(page: ReviewsPage): string | undefined {
  return page.reviews.map(r => r.submittedAt).filter((t): t is string => !!t).sort().pop()
}

function toFeedback(id: string, kind: 'review' | 'comment', login: string | undefined, body: string | null, me: string): Feedback | undefined {
  const author = login ?? 'ghost'
  if (author !== me) return { id, kind, author }
  // Skip my own replies (or Claude's on my behalf) unless they're a command.
  if (!COMMAND_PREFIX.test(body ?? '')) return undefined
  return { id, kind: 'command', author, instruction: (body ?? '').replace(COMMAND_PREFIX, '').trim() }
}

/** The prompt that asks Claude to address `items` with `skill`. */
export function buildMessage(pr: Pick<PullRequest, 'title' | 'url'>, items: Feedback[], skill: string): string {
  const authors = [...new Set(items.filter(i => i.kind !== 'command').map(i => i.author))].sort()
  let message = `New GitHub activity on your PR "${pr.title}": ${pr.url}\nPlease use the ${skill} skill to address it.`
  if (authors.length) message += `\nFeedback from ${authors.join(', ')}.`
  for (const item of items) {
    if (item.kind !== 'command') continue
    const where = item.location ? ` on ${item.location}` : ''
    message += `\nInstruction from the PR author${where} (${item.id}):\n${item.instruction}`
  }
  return message
}

/** A skill's name from the skill option, which may be a name or the skill's folder. */
export function skillName(option: string): string {
  return option.replace(/\/+$/, '').split('/').pop() || option
}

/** Whether version `a` is older than `b` ("0.2.3" < "0.3.0"); a missing version is older. */
export function isOlderVersion(a: string | undefined, b: string): boolean {
  if (!a) return true
  const [x, y] = [a, b].map(v => v.split('.').map(Number))
  for (let i = 0; i < Math.max(x!.length, y!.length); i++) {
    const d = (x![i] ?? 0) - (y![i] ?? 0)
    if (d) return d < 0
  }
  return false
}
