#!/usr/bin/env ruby

# Must give iTerm access to send key strokes via osascript (this is used to
# switch iTerm backgrounds)
# https://apple.stackexchange.com/questions/291574/osascript-is-not-allowed-assistive-access-1728

require 'msgpack/rpc'
require 'msgpack/rpc/transport/unix'

module ToggleColorScheme
  extend self

  DARK_THEME  = 'dark'.freeze
  LIGHT_THEME = 'light'.freeze

  UP_KEY   = 126
  DOWN_KEY = 125

  COLOR_SCHEME_FILE = File.expand_path('~/.vim-colorscheme')

  def execute
    new_color_scheme = light_theme? ? DARK_THEME : LIGHT_THEME
    save_new_color_scheme(new_color_scheme)
    toggle_iterm_color_scheme(new_color_scheme)
    toggle_running_vim_sessions_color_schemes
  end

  private

  def save_new_color_scheme(new_color_scheme)
    File.open(COLOR_SCHEME_FILE, 'w') do |f|
      f.write(new_color_scheme)
    end
  end

  def toggle_iterm_color_scheme(color_scheme)
    command_key = color_scheme == DARK_THEME ? UP_KEY : DOWN_KEY
    `osascript -e 'tell application "System Events" to key code #{command_key} using {command down, control down}'`
  end

  def toggle_running_vim_sessions_color_schemes
    file_listeners = `nvr --serverlist`.split("\n")

    file_listeners.each do |file_listener|
      nvim_process = MessagePack::RPC::Client.new(MessagePack::RPC::UNIXTransport.new, file_listener)
      nvim_process.call(:nvim_command, 'LoadColorscheme')
    end
  end

  def light_theme?
    !File.exist?(COLOR_SCHEME_FILE) || File.read(COLOR_SCHEME_FILE) == 'light'
  end
end

ToggleColorScheme.execute
