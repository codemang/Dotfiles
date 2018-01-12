Description Of All Utilities
=

## Copy Commit To PR Utility

A utility which syncs the title/body of the last commit message to the
title/body of an open PR for the given git branch.

![image](/assets/images/copy_commit_to_pr.png)

### Requirements

1. Install the octokit gem for interfacing with Github.

    ```
    $ gem install octokit
    ```

2. Create a Github personal access token with access to all repo
information. This access token should be stored in a local file.
The path to that file should be stored in this environment variable.

    ```
    export OCTOKIT_REPO_ACCESS_TOKEN_FILE=/path/to/token/file
    ```

    https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/

### Usage

Run the ruby script manually.

```
$ ruby /path/to/copy_commit_to_pr.rb
```

Or, create an alias in your bashrc, zshrc, etc

```bash
function copy_commits_to_pr() {
  ruby /path/to/copy_commit_to_pr.rb
}
```

Then from the command line

```
$ copy_commits_to_pr
```
