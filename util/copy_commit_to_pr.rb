require 'octokit'

module CopyCommitToPR
  extend self

  ACCESS_TOKEN_PATH_ENV = 'OCTOKIT_REPO_ACCESS_TOKEN_FILE'

  def execute
    begin
      check_requirements!

      # Assumes the name of the directory matches the Github repo name exactly
      remote_repo = find_remote_repo_for_local_dir
      success_message("Found remote repo '#{remote_repo[:name]}'.")

      git_branch = find_current_git_branch
      pull_request = find_pull_request_for(remote_repo, git_branch)
      success_message("Found PR ##{pull_request[:number]} opened for branch '#{git_branch}'.")

      sync_commit_message(remote_repo, pull_request)
      success_message('Overwriting PR title and body with local commit message.')
    rescue StandardError => e
      error_message('There seems to be a problem.')
    end
  end


  private

  # ---- Git/Github Helpers ----

  def find_remote_repo_for_local_dir
    local_repo = File.basename(Dir.pwd)
    remote_repo = client.repos.find do |repo|
      repo[:name] == local_repo
    end

    error_message("Could not find remote repo '#{local_repo}.'") if remote_repo.nil?

    remote_repo
  end

  def find_pull_request_for(remote_repo, git_branch)
    pull_request = client.pull_requests(remote_repo[:full_name]).find do |pr|
      pr.attrs[:head][:ref] == git_branch
    end

    error_message("Could not find pull request for branch '#{git_branch}'.") if pull_request.nil?

    pull_request
  end

  def sync_commit_message(remote_repo, pull_request)
    repo_name       = remote_repo[:full_name]
    pull_request_id = pull_request[:number]
    git_message     = `git log -n 1 --pretty=format:"%b"`
    git_title       = `git log -n 1 --pretty=format:"%s"`

    client.update_pull_request(repo_name, pull_request_id, title: git_title, body: git_message)
  end

  def find_current_git_branch
    `git branch 2> /dev/null | sed -n '/^\*/s/^\* //p'`.strip
  end

  # ---- Output Helpers ----

  def success_message(msg)
    puts "==> #{msg} \e[32m\xE2\x9C\x94\e[0m"
  end

  def error_message(msg)
    puts "==> #{msg} \e[31m\xE2\x9C\x98 \e[0m"
    exit 1
  end

  # ---- Misc Helpers ----

  def check_requirements!
    access_token_path = ENV[ACCESS_TOKEN_PATH_ENV]
    if access_token_path.nil?
      error_message("You did not set the '#{ACCESS_TOKEN_PATH_ENV}' environment variable.")
    end

    begin
      access_token = read_access_token
      if access_token.nil? || access_token.empty?
        error_message("Your access token stored in '#{access_token_path}' looks empty.")
      end
    rescue Errno::ENOENT => e
      error_message("Your access token file '#{access_token_path}' does not exist.")
    end
  end

  def client
    @client ||= begin
      access_token = read_access_token
      client = Octokit::Client.new(:access_token => access_token)
      client.auto_paginate = true
      client
    end
  end

  def read_access_token
    `token_manager read github_copy_commit_to_pr`
  end
end

CopyCommitToPR.execute
