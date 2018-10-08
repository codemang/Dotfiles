#!/usr/bin/env ruby

require 'msgpack/rpc'
require 'msgpack/rpc/transport/unix'

module ToggleColorScheme
  extend self

  DARK_THEME  = 'dark'
  LIGHT_THEME = 'light'

  UP_KEY   = 126
  DOWN_KEY = 125

  RUNNING_VIM_TRACKER_FILE = File.expand_path('~/.nvim-trackers')
  COLOR_SCHEME_FILE        = File.expand_path('~/.color-scheme-env')


  def execute
    new_color_scheme = is_light_theme? ? DARK_THEME : LIGHT_THEME

    save_new_color_scheme(new_color_scheme)
    toggle_iterm_color_scheme(new_color_scheme)
    toggle_running_vim_sessions_color_schemes(new_color_scheme)
  end


  private

  def save_new_color_scheme(new_color_scheme)
    File.open(COLOR_SCHEME_FILE, 'w') do |f|
      f.write(new_color_scheme)
    end

  end

  def toggle_iterm_color_scheme(color_scheme)
    command_key = (color_scheme == DARK_THEME) ? UP_KEY : DOWN_KEY
    `osascript -e 'tell application "System Events" to key code #{command_key} using {command down, control down}'`
  end

  def toggle_running_vim_sessions_color_schemes(color_scheme)
    potential_vim_pids = File.read(RUNNING_VIM_TRACKER_FILE).split("\n").select do |line|
      !line.nil? && !line.empty?
    end

    running_vim_pids = potential_vim_pids.map do |line|
      Thread.new do
        begin
          proc_num = line.strip
          file_listener =  "/tmp/nvim-#{proc_num}"
          nvim = MessagePack::RPC::Client.new(MessagePack::RPC::UNIXTransport.new, file_listener)
          result = nvim.call(:nvim_command, 'LoadColorscheme')
          Thread.current[:output] = proc_num
        rescue StandardError => e
          Thread.current[:output] = nil
        end
      end
    end.map(&:join).map{|thr| thr[:output]}.compact

    File.open(RUNNING_VIM_TRACKER_FILE, 'w') do |f|
      f.write( running_vim_pids.join("\n") )
    end
  end


  def is_light_theme?
    !File.exists?(COLOR_SCHEME_FILE) || File.read(COLOR_SCHEME_FILE) == 'light'
  end
end

ToggleColorScheme.execute
