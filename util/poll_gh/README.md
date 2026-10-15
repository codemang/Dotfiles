# poll_gh

Polls GitHub for new reviews and comments on your open PRs. When one arrives, it tells
the local Claude Code session working on that PR's branch to address it.

## Requirements

- [`gh`](https://cli.github.com/), logged in to your GitHub host
    - For Mac: `brew install gh`
    - For WSL:
        ```
        (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
        ```
    - Once installed, run `gh auth login`

- A skill for addressing PR feedback, e.g. `~/.claude/skills/address-pr-feedback/SKILL.md`

## Setup

1. Clone this repo and navigate to it.
1. Create your config from the template:

   ```sh
   mkdir -p ~/.config/poll_gh
   cp config.template.ini ~/.config/poll_gh/config.ini
   ```

1. Update the config file you just created with the correct values. There are 3 values to update:
    1. The path to the `gh` executable, typical examples are included in the config file.
    1. The path to the `claude` executable, typical examples are included in the config file.
    1. The path to the claude skill directory that you want to execute, e.g `~/.claude/skills/address-pr-feedback`. You must create this!

1. Check that everything is set up:

   ```sh
   ./main.py --healthcheck
   ```

   Every line should say `PASS` (or `SKIP`). Each `FAIL` says what to fix.

1. Schedule it to run every 10 seconds (see below).

## Scheduling

Run the commands below from this directory. Schedulers start with a bare `PATH`, so
they bake in the full path to your current `python3` rather than relying on the
`#!/usr/bin/env python3` shebang. That way the scheduler uses the same Python the
healthcheck passed with.

### macOS (launchd)

Write the plist (the healthcheck looks for the label `com.$USER.poll_gh`):

```sh
cat > ~/Library/LaunchAgents/com.$USER.poll_gh.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.$USER.poll_gh</string>
  <key>ProgramArguments</key>
  <array>
    <string>$(command -v python3)</string>
    <string>$PWD/main.py</string>
  </array>
  <key>StartInterval</key>
  <integer>10</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/poll_gh.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/poll_gh.log</string>
</dict>
</plist>
EOF
```

Then load it:

```sh
launchctl load ~/Library/LaunchAgents/com.$USER.poll_gh.plist
```

### Linux / WSL (systemd)

1. Make sure systemd is running: `systemctl --user status` should work. On WSL, if it
   doesn't, add this to `/etc/wsl.conf`, then run `wsl --shutdown` from Windows:

   ```ini
   [boot]
   systemd=true
   ```

2. Write the service and timer:

   ```sh
   mkdir -p ~/.config/systemd/user
   cat > ~/.config/systemd/user/poll_gh.service <<EOF
   [Unit]
   Description=Relay GitHub PR feedback to Claude sessions

   [Service]
   Type=oneshot
   ExecStart=$(command -v python3) $PWD/main.py
   EOF
   cat > ~/.config/systemd/user/poll_gh.timer <<EOF
   [Unit]
   Description=Run poll_gh every 10 seconds

   [Timer]
   OnBootSec=10s
   OnUnitActiveSec=10s
   AccuracySec=1s

   [Install]
   WantedBy=timers.target
   EOF
   ```

3. Start the timer:

   ```sh
   systemctl --user daemon-reload
   systemctl --user enable --now poll_gh.timer
   ```

Logs go to the journal: `journalctl --user -u poll_gh -f`.

`Type=oneshot` means a slow run delays the next one instead of overlapping it. On WSL,
the timer only runs while WSL does; WSL shuts down shortly after its last terminal
closes. That's fine, since the Claude sessions it relays to live in WSL too.

## Usage

```sh
./main.py                # poll once and relay new feedback
./main.py --dry-run      # poll once, log what would be relayed, send nothing
./main.py --healthcheck  # check dependencies and config, then exit
```

To re-send feedback for a PR, delete its lines from `seen_ids`:

```sh
grep -v pull/668 ~/.local/state/poll_gh/seen_ids > /tmp/seen && mv /tmp/seen ~/.local/state/poll_gh/seen_ids
```

## How it works

1. Every run, `main.py` fetches your open PRs and their reviews/comments with `gh api graphql`.
2. Anything not already listed in `~/.local/state/poll_gh/seen_ids` is new. Your own
   comments and unsubmitted reviews are ignored.
3. For each PR with new feedback, it finds the most recently started Claude session
   whose working directory is on the PR's repo and branch (`claude agents --json`).
4. It runs a headless `claude -p` that sends that session a message asking it to use
   your PR-feedback skill.

The first run only records existing feedback, so you won't get a flood of old comments.
