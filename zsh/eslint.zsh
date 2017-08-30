# Lint any tracked files that have changes
function eslint_changes() {
  changed_files=$(git diff --name-only `git merge-base origin/master HEAD` | grep -E 'js$|jsx$|es6$')
  changed_files_without_newlines=$(echo $changed_files | tr '\n' ' ')

  if [[ -z "${changed_files// }" ]]; then
    echo "There are no changed files that need linting."
  else
    echo "--- You have changed the following files ---"
    echo $changed_files

    echo "\n--- Starting linting process ---"
    eval "./node_modules/eslint/bin/eslint.js --color --cache $changed_files_without_newlines"
    if [ $? -eq 0 ]; then
      echo "There are no linting errors in the changed files"
    fi
  fi
}

function eslint_compare() {
  ruby ~/.eslint_compare.rb
}
