# Github Comments Trigger for Claude

A script that polls GitHub for new reviews and comments on your open PRs. When
one arrives, it tells the local Claude Code session working on that PR's branch
to address it.

## Requirements

- The Github CLI client - [`gh`](https://cli.github.com/)
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
    - Once installed, run `gh auth login` and fill in the instructions as follows:
        ```
        ? Where do you use GitHub? Other
        ? Hostname: bbgithub.dev.bloomberg.com
        ? What is your preferred protocol for Git operations on this host? HTTPS
        ? Authenticate Git with your GitHub credentials? Yes
        ? How would you like to authenticate GitHub CLI? Login with a web browser
        ```
    - Then follow the instructions to open github and verify your identity with an auth code.
    - Test your connection via `gh auth status`


- A skill for addressing PR feedback, e.g. `~/.claude/skills/address-pr-feedback/SKILL.md`.
    - If you already have a skill that you want triggered whenever PR comments come in, great! We'll show you how to configure that below.
    - If you don't yet have a skill, we've included a sample one that works well (more below).

## Setup

1. Clone this repo and navigate to it.

1. Create a skill that will be triggered in Claude to handle the PR comments. If you want to use the repo-supplied skill, do:
    ```
    mkdir -p ~/.claude/skills/address-pr-feedback
    cp sample_address_pr_feedback_skill.md ~/.claude/skills/address-pr-feedback/SKILL.md
    ``````

1. Create the script config from the template:

   ```sh
   cp config.template.ini config.ini
   ```

1. Update the `config.ini` you just created (it's gitignored):
    1. Set `skill_dir` to the claude skill directory that you want to execute, e.g `~/.claude/skills/address-pr-feedback`. You must create this!

1. Check that everything is set up:

   ```sh
   ./main.py --healthcheck
   ```

   Every line should say `PASS`. Each `FAIL` says what to fix.

**At this point, the script is able to read PR comments from Github and
interact with local Claude instances. You now need to schedule it to run every
10 seconds.**

## Scheduling

### macOS (launchd)

Write the plist:

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

1. Make sure systemd is running: `systemctl --user status` should work.
    1. **If it doesn't**, add this to `/etc/wsl.conf`, then run `wsl --shutdown` from Windows:
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
## Commenting on your own PR

If you want to leave comments on your own PR and have them trigger Claude,
prefix the comment with `/claude` or `@claude`, e.g `/claude rename this to
isDone`. Your other comments, like replies to reviewers, are ignored.

## Troubleshooting

If Github comments are not triggering Claude to address them, you can run the debug script:

```sh
./main.py --debug <PR_URL>
```

This will print a list of events and actions that have been seen by the script.
This typically highlights whatever the issue is, which can include:

1. Is there a Claude instance running locally on the same branch as the PR that
   has comments? If not, there is no Claude instance to send instructions to.

1. Is the script healthy? Run `./main.py --healthcheck` to confirm.

If you'd like to see the raw log of events the script has processed, they can be found at `~/.local/state/poll_gh/seen_ids`.

## How it works

1. Every run, `main.py` fetches your open PRs and their reviews/comments with `gh api graphql`.
1. Unsubmitted reviews are ignored, and so are your own comments unless they start with
   `/claude` or `@claude`.
1. For every PR feedback (i.e a collection of comments from a single
   commenter), a deterministic unique ID is generated.
1. Feedback IDs that have already been sent to Claude are stored in
   `~/.local/state/poll_gh/seen_ids`, to prevent re-processing the same
feedback over and over.
3. For each PR with new feedback, it finds the most recently started Claude session
   whose working directory is on the PR's repo and branch (`claude agents --json`).
4. It runs a headless `claude -p` that sends that session a message asking it to use
   your PR-feedback skill.
