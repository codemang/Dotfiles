#!/usr/bin/env python3
"""Poll GitHub for new reviews/comments on my open PRs and relay them to the
local Claude session working on that PR's branch.

See README.md for setup. Settings come from ~/.config/poll_gh/config.ini;
start from config.template.ini next to this file.

Usage: main.py [--dry-run | --healthcheck]
  --dry-run      log relays instead of sending them
  --healthcheck  check that every dependency is set up, then exit
"""

# Lets Python 3.9 accept `str | None` annotations.
from __future__ import annotations

import configparser
import json
import os
import pwd
import shutil
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

CONFIG_FILE = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "poll_gh/config.ini"
REQUIRED_SETTINGS = ("gh", "claude", "skill_dir")
CONFIG_TEMPLATE = Path(__file__).with_name("config.template.ini")
# Set from CONFIG_FILE by load_config().
GH: str
CLAUDE: str
SKILL_DIR: Path
GH_HOST = "bbgithub.dev.bloomberg.com"
SEEN_FILE = Path.home() / ".local/state/poll_gh/seen_ids"
# $USER may be unset under launchd/cron, so fall back to the user database.
USER = os.environ.get("USER") or pwd.getpwuid(os.getuid()).pw_name
LAUNCHD_LABEL = f"com.{USER}.poll_gh"
SYSTEMD_TIMER = "poll_gh.timer"
PLIST = Path.home() / f"Library/LaunchAgents/{LAUNCHD_LABEL}.plist"
RELAY_TIMEOUT_S = 120
# The user's login shell from the user database, not $SHELL, which launchd doesn't set.
LOGIN_SHELL = pwd.getpwuid(os.getuid()).pw_shell or "/bin/sh"

# Environment for subprocesses. Set by load_config().
ENV: dict[str, str]

QUERY = """
{
  viewer {
    login
    pullRequests(states: OPEN, first: 50) {
      nodes {
        title url headRefName
        repository { nameWithOwner name }
        headRepository { name }
        reviews(last: 50) { nodes { id state author { login } } }
        comments(last: 50) { nodes { id author { login } } }
      }
    }
  }
}
"""


def load_config() -> None:
    """Set GH, CLAUDE, SKILL_DIR and ENV from CONFIG_FILE. Raises RuntimeError saying what to fix."""
    global GH, CLAUDE, SKILL_DIR, ENV
    if not CONFIG_FILE.exists():
        raise RuntimeError(f"missing {CONFIG_FILE}; run: cp {CONFIG_TEMPLATE} {CONFIG_FILE}, then edit it")
    parser = configparser.ConfigParser(interpolation=None)
    no_section = RuntimeError(f"{CONFIG_FILE} needs a [poll_gh] section; see {CONFIG_TEMPLATE}")
    try:
        parser.read(CONFIG_FILE)
    except configparser.MissingSectionHeaderError:
        raise no_section
    except configparser.Error as e:
        raise RuntimeError(f"can't parse {CONFIG_FILE}: {e}")
    if not parser.has_section("poll_gh"):
        raise no_section
    config = parser["poll_gh"]
    missing = [key for key in REQUIRED_SETTINGS if not config.get(key)]
    if missing:
        raise RuntimeError(f"{CONFIG_FILE} is missing: {', '.join(missing)}")
    GH = os.path.expanduser(config["gh"])
    CLAUDE = os.path.expanduser(config["claude"])
    SKILL_DIR = Path(config["skill_dir"]).expanduser()
    # Schedulers start us with a bare PATH. Put the gh and claude dirs first: an npm-installed
    # claude is a node script, and node is normally installed next to it.
    path = [os.path.dirname(CLAUDE), os.path.dirname(GH), os.environ.get("PATH", "/usr/bin:/bin")]
    ENV = {**os.environ, "GH_HOST": GH_HOST, "PATH": os.pathsep.join(path)}


def log(msg: str) -> None:
    print(f"{datetime.now():%Y-%m-%d %H:%M:%S} {msg}", flush=True)


def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, env=ENV, **kwargs)


def fetch_feedback() -> tuple[list[dict], list[dict]]:
    """Return (open PRs, feedback items). Each item: id, kind, author, state, pr."""
    result = run([GH, "api", "graphql", "-f", f"query={QUERY}"])
    if result.returncode != 0:
        raise RuntimeError(f"gh api failed: {result.stderr.strip()}")

    viewer = json.loads(result.stdout)["data"]["viewer"]
    me = viewer["login"]
    prs = viewer["pullRequests"]["nodes"]

    items = []
    for pr in prs:
        for kind, nodes in (
            ("review", pr["reviews"]["nodes"]),
            ("comment", pr["comments"]["nodes"]),
        ):
            for node in nodes:
                author = (node["author"] or {}).get("login", "ghost")
                # Skip my own replies (or Claude's on my behalf) and unsubmitted reviews.
                if author == me or node.get("state") == "PENDING":
                    continue
                items.append(
                    {
                        "id": node["id"],
                        "kind": kind,
                        "author": author,
                        "state": node.get("state", "COMMENTED"),
                        "pr": pr,
                    }
                )
    return prs, items


def git(cwd: str, *args: str) -> str:
    return run(["git", "-C", cwd, *args]).stdout.strip()


def find_session(pr: dict) -> str | None:
    """Name of the most recently started Claude session on the PR's repo + branch."""
    result = run([CLAUDE, "agents", "--json"])
    if result.returncode != 0:
        log(f"ERROR claude agents failed: {result.stderr.strip()}")
        return None

    # Match on repo name only, not owner: repos get transferred/renamed (GitHub redirects
    # the old URL, so local remotes keep the old owner), and forks have a different owner.
    repo_names = {pr["repository"]["name"], (pr["headRepository"] or {}).get("name")}
    sessions = sorted(json.loads(result.stdout), key=lambda s: s["startedAt"], reverse=True)
    for session in sessions:
        cwd = session.get("cwd")
        if not cwd or not session.get("name"):
            continue
        remote_names = {
            line.split()[1].removesuffix(".git").rsplit("/", 1)[-1]
            for line in git(cwd, "remote", "-v").splitlines()
        }
        if remote_names & repo_names and git(cwd, "branch", "--show-current") == pr["headRefName"]:
            return session["name"]
    return None


def in_login_shell(cmd: list[str]) -> list[str]:
    """Wrap `cmd` to run in an interactive login shell, so it sees my shell environment.
    "$0" "$@" passes the args through without re-quoting (needs a POSIX-style shell)."""
    return [LOGIN_SHELL, "-lic", 'exec "$0" "$@"', *cmd]


def relay(session: str, message: str) -> None:
    """Have a headless Claude deliver `message` to `session` via SendMessage."""
    prompt = (
        f"Use the SendMessage tool to send the message below, verbatim, to the session "
        f"named {session!r}. Do nothing else. Reply with exactly OK, or the error.\n\n"
        f"{message}"
    )
    # claude's apiKeyHelper needs my shell environment, which launchd doesn't provide.
    result = run(
        in_login_shell([
            CLAUDE, "-p", prompt,
            "--model", "haiku",
            "--allowedTools", "SendMessage ListAgents ToolSearch",
        ]),
        cwd="/tmp",
        timeout=RELAY_TIMEOUT_S,
    )
    # Shell startup files may print noise, so only the last line of stdout is the reply.
    lines = result.stdout.strip().splitlines()
    if result.returncode != 0 or not lines or lines[-1].strip() != "OK":
        output = (result.stdout + result.stderr).strip()
        raise RuntimeError(f"relay to {session} failed: {output[-500:]}")


def seen_line(item: dict, status: str) -> str:
    """Tab-separated record: id, time, PR url, kind, author, status. Only id is used for
    de-duping; the rest is so you can e.g. `grep -v pull/668` to re-send a PR's feedback."""
    fields = [item["id"], f"{datetime.now():%Y-%m-%d %H:%M:%S}", item["pr"]["url"], item["kind"], item["author"], status]
    return "\t".join(fields) + "\n"


class SkipCheck(Exception):
    """Raised by a healthcheck that doesn't apply on this platform."""


def healthcheck() -> int:
    """Check each dependency the poller needs, print PASS/FAIL per check."""

    def require(ok: bool, ok_detail: str, fail_detail: str) -> str:
        if not ok:
            raise RuntimeError(fail_detail)
        return ok_detail

    def check_gh_auth() -> str:
        result = run([GH, "auth", "status", "--hostname", GH_HOST])
        if result.returncode != 0:
            raise RuntimeError(f"not logged in; run: gh auth login --hostname {GH_HOST}")
        return GH_HOST

    def check_gh_query() -> str:
        prs, items = fetch_feedback()
        return f"{len(prs)} open PRs, {len(items)} reviews/comments"

    def check_claude_agents() -> str:
        result = run([CLAUDE, "agents", "--json"])
        if result.returncode != 0:
            raise RuntimeError(result.stderr.strip())
        return f"{len(json.loads(result.stdout))} sessions"

    def check_claude_headless() -> str:
        # Same login-shell invocation as relay(), so apiKeyHelper is exercised too.
        result = run(
            in_login_shell([CLAUDE, "-p", "Reply with exactly OK", "--model", "haiku"]),
            cwd="/tmp",
            timeout=RELAY_TIMEOUT_S,
        )
        lines = result.stdout.strip().splitlines()
        if result.returncode != 0 or not lines or lines[-1].strip() != "OK":
            raise RuntimeError((result.stdout + result.stderr).strip()[-500:])
        return "replied OK"

    def check_skill() -> str:
        if not (SKILL_DIR / "SKILL.md").exists():
            raise RuntimeError(f"missing {SKILL_DIR}/SKILL.md; fix skill_dir in {CONFIG_FILE}")
        return str(SKILL_DIR)

    def check_state_dir() -> str:
        SEEN_FILE.parent.mkdir(parents=True, exist_ok=True)
        if not os.access(SEEN_FILE.parent, os.W_OK):
            raise RuntimeError(f"{SEEN_FILE.parent} not writable")
        return "seeded" if SEEN_FILE.exists() else "not seeded yet (first run will seed)"

    def check_scheduler() -> str:
        if sys.platform == "darwin":
            if not PLIST.exists():
                raise RuntimeError(f"missing {PLIST}; see README.md")
            if run(["launchctl", "list", LAUNCHD_LABEL]).returncode != 0:
                raise RuntimeError(f"not loaded; run: launchctl load {PLIST}")
            return f"launchd job {LAUNCHD_LABEL} loaded"
        if shutil.which("systemctl"):
            if run(["systemctl", "--user", "is-active", SYSTEMD_TIMER]).returncode != 0:
                raise RuntimeError(f"not active; see README.md, then: systemctl --user enable --now {SYSTEMD_TIMER}")
            return f"systemd {SYSTEMD_TIMER} active"
        raise SkipCheck("no launchd or systemd; schedule this script yourself")

    checks = [
        ("python >= 3.9", lambda: require(sys.version_info >= (3, 9), sys.version.split()[0], sys.version)),
        ("config", lambda: load_config() or str(CONFIG_FILE)),
        ("gh installed", lambda: require(os.access(GH, os.X_OK), GH, f"{GH} not found; fix gh in {CONFIG_FILE}")),
        ("claude installed", lambda: require(os.access(CLAUDE, os.X_OK), CLAUDE, f"{CLAUDE} not found; fix claude in {CONFIG_FILE}")),
        ("gh auth", check_gh_auth),
        ("gh graphql query", check_gh_query),
        ("claude agents --json", check_claude_agents),
        (f"claude -p via login shell ({LOGIN_SHELL})", check_claude_headless),
        ("skill_dir", check_skill),
        ("state dir", check_state_dir),
        ("scheduler", check_scheduler),
    ]
    failed = skipped = 0
    for name, check in checks:
        try:
            print(f"PASS  {name}: {check()}")
        except SkipCheck as e:
            skipped += 1
            print(f"SKIP  {name}: {e}")
        except Exception as e:
            failed += 1
            print(f"FAIL  {name}: {e}")
            if name.startswith(("python", "config")):
                print("\nStopping: the remaining checks need this one to pass.")
                return 1
    print(f"\n{len(checks) - failed - skipped} passed, {failed} failed, {skipped} skipped")
    return 1 if failed else 0


def main() -> int:
    if "--healthcheck" in sys.argv:
        return healthcheck()

    try:
        load_config()
    except Exception as e:
        log(f"ERROR {e}")
        return 1

    dry_run = "--dry-run" in sys.argv

    try:
        _, items = fetch_feedback()
    except Exception as e:
        log(f"ERROR {e}")
        return 1

    # First run: record existing feedback without relaying it.
    if not SEEN_FILE.exists():
        SEEN_FILE.parent.mkdir(parents=True, exist_ok=True)
        SEEN_FILE.write_text("".join(seen_line(item, "seeded") for item in items))
        log(f"seeded {len(items)} existing reviews/comments")
        return 0

    seen = {line.split("\t", 1)[0] for line in SEEN_FILE.read_text().splitlines()}
    new_by_pr = defaultdict(list)
    for item in items:
        if item["id"] not in seen:
            new_by_pr[item["pr"]["url"]].append(item)

    for new in new_by_pr.values():
        pr = new[0]["pr"]
        for item in new:
            log(f"NEW {item['kind']} {item['state']} by {item['author']} on \"{pr['title']}\" {pr['url']}")

        session = find_session(pr)
        if session is None:
            status = "no-session"
            log(f"no Claude session on {pr['repository']['nameWithOwner']}:{pr['headRefName']}, skipping relay")
        else:
            authors = ", ".join(sorted({item["author"] for item in new}))
            message = (
                f"New GitHub feedback on your PR \"{pr['title']}\" from {authors}: {pr['url']}\n"
                f"Please use the {SKILL_DIR.name} skill to address it."
            )
            if dry_run:
                status = f"dry-run:{session}"
                log(f"DRY RUN would relay to {session}: {message!r}")
            else:
                try:
                    relay(session, message)
                    status = f"relayed:{session}"
                    log(f"relayed to {session}")
                except Exception as e:
                    status = "error"
                    log(f"ERROR {e}")

        # Mark seen even if the relay failed, so one failure doesn't re-fire every 10s.
        with SEEN_FILE.open("a") as f:
            f.writelines(seen_line(item, status) for item in new)

    return 0


if __name__ == "__main__":
    sys.exit(main())
