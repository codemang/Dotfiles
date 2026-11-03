# Open the current branch's PR, or the compare page to create one if none exists
open_pr() {
  # Ensure a default repo is set
  if gh repo set-default --view 2>&1 | grep -q "No default remote repository"; then
    # Try upstream first, then fall back to origin
    local remote_url
    remote_url=$(git config --get remote.upstream.url)
    if [ -z "$remote_url" ]; then
      remote_url=$(git config --get remote.origin.url)
    fi

    if [ -z "$remote_url" ]; then
      echo "Error: No upstream or origin remote configured" >&2
      return 1
    fi

    # Extract owner/repo from the remote URL
    # Handles both SSH (git@github.com:owner/repo.git) and HTTPS (https://github.com/owner/repo.git)
    local repo
    repo=$(echo "$remote_url" | sed -E 's#^(https://|git@)[^/:]+[/:]##' | sed 's/\.git$//')

    if [ -z "$repo" ]; then
      echo "Error: Could not parse repository from remote: $remote_url" >&2
      return 1
    fi

    gh repo set-default "$repo"
  fi

  gh pr view --web 2>/dev/null || gh pr create --web
}
