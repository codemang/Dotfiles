#!/usr/bin/env ruby

require 'json'
require 'time'
require 'byebug'

module CircleOutput
  extend self

  def find_output_for_branch
    @start_time = Time.now
    puts_formatted "Project: #{project}"
    puts_formatted "Git Branch: #{git_branch}"
    puts_formatted "Build num: #{build_num}"

    had_to_wait = track_status
    completed_build = json_get("#{project}/#{build_num}")

    if completed_build['status'] == 'success' || completed_build['status'] == 'fixed'
      puts_formatted 'All tests passed!'
      send_osx_notification if had_to_wait
      return
    end

    send_osx_notification
    show_failed_specs(completed_build)
    send_osx_notification if had_to_wait
  end

  def send_osx_notification
    `osascript -e 'display notification "Your build has completed" with title "Circle"'`
  end

  def show_failed_specs(completed_build)
    build_summary = json_get("#{project}/#{build_num}")

    output_urls = build_summary['steps'].select do |step|
      step['name'] =~ /bundle exec rspec/
    end.map do |step|
      step['actions']
    end.first.select do |action|
      action['exit_code'] != 0
    end.map do |action|
      action['output_url']
    end

    failed_specs = output_urls.map do |output_url|
      build_output = `curl -s --compressed "#{output_url}"`
      build_output.match(/Failed examples(.*?)Random/)[0].scan(/\.\/spec.*?\d+/)
    end.flatten

    puts_formatted("#{failed_specs.count} Specs Failed")

    failed_specs.each do |failed_spec|
      puts(failed_spec)
    end
  end

  def git_branch
    @git_branch ||= `git rev-parse --symbolic-full-name --abbrev-ref HEAD`.strip
  end

  def project
    @project ||= File.basename(`pwd`).strip
  end

  def build_num
    @build_num ||= begin
      projects = json_get(project)
      my_project = projects.find do |project|
        project['branch'] == git_branch
      end
      if my_project.nil?
        raise ArgumentError
      end
      my_project['build_num']
    end
  end

  def track_status
    had_to_sleep = false
    loop do
      build = json_get("#{project}/#{build_num}")
      if build['status'] != 'running' && build['status'] != 'queued'
        puts
        break build
      end
      had_to_sleep = true
      build_time = ((Time.now - @start_time).to_f / 60).round(2)
      STDOUT.write "\r==> Build Time: #{build_time} minutes"
      sleep 3
    end
    had_to_sleep
  end

  def json_get(path)
    circle_token = `token_manager read circle-token`
    JSON.parse(`curl -s -u #{circle_token}: https://circle.bubtools.net/api/v1.1/project/github/BookBub/#{path}`)
  end

  def puts_formatted(msg)
    puts "==> #{msg}"
  end
end

CircleOutput.find_output_for_branch
