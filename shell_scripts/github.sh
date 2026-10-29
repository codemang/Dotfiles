# Open the current branch's PR, or the compare page to create one if none exists
open_pr() {
  gh pr view --web 2>/dev/null || gh pr create --web
}
