#!/bin/env ruby
# Scoutix the bot
# Copyright (C) 2013 Christos Triantafyllidis
#
# Scoutix the bot is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Scoutix the bot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
APP_PATH = File.dirname(File.expand_path(__FILE__)).to_s
$LOAD_PATH << APP_PATH
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('./Gemfile', APP_PATH)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'sqlite3'
require 'cinch'
require 'yaml'

$config = YAML.load(File.read(File.expand_path(File.join(File.dirname(__FILE__), 'etc', 'config.yml'))))

$plugin_options = Hash.new
$plugins = []

$config['plugins'].each{|plugin| 
  if plugin[1][:enabled] then
    require 'cinch/plugins/' + plugin[0].scan(/[A-Z][a-z]*/).collect {|name| name.downcase}.join("_")
    plugin_object = Object.const_get("Cinch::Plugins::" + plugin[0])
    $plugins << plugin_object
    $plugin_options[plugin_object] = plugin[1].reject{|key| key == :enabled}
  end
}

bot = Cinch::Bot.new do
  configure do |c|
    c.server     = $config['irc']['server']
    c.user       = $config['irc']['user']
    c.nick       = $config['irc']['nick']
    c.realname   = $config['irc']['realname']
    c.password   = $config['irc']['password']
    c.channels   = $config['irc']['channels']
    c.port       = $config['irc']['port'] || '6667'
    c.ssl.use    = $config['irc']['ssl'] || false
    c.ssl.verify = $config['irc']['verify_ssl'].nil? ? true : $config['irc']['verify_ssl']
    c.sasl.username = $config['irc']['sasl_username']
    c.sasl.password = $config['irc']['sasl_password']
    c.plugins.plugins = $plugins
    c.plugins.options = $plugin_options
  end

  file = open("var/cinch.log", "a")
  file.sync = true
  loggers.push(Cinch::Logger::FormattedLogger.new(file))
end

bot.start
