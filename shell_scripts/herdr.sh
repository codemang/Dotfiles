#!/bin/bash

# herdr-reviewr, diffing against the local copy of the repo's default branch
# instead of a remote's. A --base you pass wins.
hr() {
  local arg base candidate
  for arg in "$@"; do
    [[ "$arg" == --base || "$arg" == --base=* ]] && { herdr-reviewr "$@"; return; }
  done
  # The default branch: what origin/HEAD names when it's set, else main or master.
  # Not origin/HEAD alone: it's often unset, and origin may be a stale fork.
  base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2> /dev/null)
  for candidate in "${base#origin/}" main master; do
    if [[ -n "$candidate" ]] && git show-ref --verify --quiet "refs/heads/$candidate"; then
      herdr-reviewr --base "$candidate" "$@"
      return
    fi
  done
  herdr-reviewr "$@"
}

# Open a GitHub PR for review in a new Herdr workspace.
#
# Finds the local clone with z (cloning into $DEV_DIR, default ~/projects, if
# there isn't one), checks the PR branch out into a git worktree inside the clone (<repo>/worktrees/<branch>), and opens a workspace with
# herdr-reviewr on the left showing the PR's diff against the local copy of its
# base branch (updated from origin first), a
# shell top-right, and claude bottom-right. If a review workspace for the PR is
# already open, focuses it instead.
#
# With no argument, picks from the open PRs awaiting your review with fzf.
#
# Usage: review_pr [pr_url]
review_pr() {
  local url=$1
  if [[ -z "$url" ]]; then
    url=$(gh search prs is:open is:pr user-review-requested:@me archived:false --limit 100 \
        --json url,number,title,repository \
        --jq '.[] | "\(.url)\t\(.repository.nameWithOwner)#\(.number)\t\(.title)"' \
      | fzf --delimiter='\t' --with-nth=2.. --prompt='Review PR> ' \
      | cut -f1)
    [[ -z "$url" ]] && return 0
  fi

  local repo
  repo=$(sed -E 's#^https?://[^/]+/[^/]+/([^/]+)/pull/[0-9]+.*#\1#' <<< "$url")
  if [[ "$repo" == "$url" ]]; then
    echo "review_pr: not a PR URL: $url" >&2
    return 1
  fi

  local branch base_branch
  { read -r branch; read -r base_branch; } < <(gh pr view "$url" --json headRefName,baseRefName --jq '.headRefName, .baseRefName')
  [[ -z "$branch" ]] && return 1

  local label="PR Review: $branch" workspace_id
  workspace_id=$(herdr workspace list \
    | jq -r --arg label "$label" '.result.workspaces[] | select(.label == $label) | .workspace_id' \
    | head -n 1)
  if [[ -n "$workspace_id" ]]; then
    herdr workspace focus "$workspace_id" > /dev/null
    return
  fi

  # Walk z's matches from best to worst and take the first one that's a clone
  # of the repo. Resolve worktrees back to their main clone.
  local repo_dir="" candidate common_dir
  while read -r candidate; do
    common_dir=$(git -C "$candidate" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || continue
    candidate=$(dirname "$common_dir")
    if git -C "$candidate" remote -v | grep -qE "[/:][^/]+/$repo(\.git)?[[:space:]]"; then
      repo_dir=$candidate
      break
    fi
  done < <(_z -l "$repo" 2>&1 | sort -rn | awk '{ $1 = ""; sub(/^ /, ""); print }')

  # z doesn't know a clone, so clone into $DEV_DIR (or reuse one already there).
  if [[ -z "$repo_dir" ]]; then
    repo_dir="${DEV_DIR:-$HOME/projects}/$repo"
    if [[ ! -d "$repo_dir/.git" ]]; then
      gh repo clone "${url%%/pull/*}" "$repo_dir" || return 1
    fi
  fi

  local worktree_dir
  worktree_dir="$repo_dir/worktrees/${branch//\//-}"

  # Keep the worktrees out of the main clone's 'git status'.
  local exclude_file="$repo_dir/.git/info/exclude"
  grep -qxF '/worktrees/' "$exclude_file" 2>/dev/null || echo '/worktrees/' >> "$exclude_file"

  if [[ ! -d "$worktree_dir" ]]; then
    git -C "$repo_dir" worktree add --detach "$worktree_dir" || return 1
  fi

  # 'gh pr checkout' adds the fork's remote if needed. Rerunning it on an
  # existing worktree pulls the latest commits.
  cd "$worktree_dir" || return 1
  gh pr checkout "$url" || return 1

  local left_pane top_right_pane bottom_right_pane
  left_pane=$(herdr workspace create --cwd "$worktree_dir" --label "$label" --focus \
    | jq -r .result.root_pane.pane_id) || return 1
  top_right_pane=$(herdr pane split "$left_pane" --direction right --cwd "$worktree_dir" --no-focus \
    | jq -r .result.pane.pane_id) || return 1
  bottom_right_pane=$(herdr pane split "$top_right_pane" --direction down --cwd "$worktree_dir" --no-focus \
    | jq -r .result.pane.pane_id) || return 1

  herdr pane run "$left_pane" "herdr-reviewr --base $base_branch" > /dev/null
  herdr pane run "$bottom_right_pane" claude > /dev/null
}
