# This file is part of Scoutix the bot
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
module Cinch
  module Plugins
    class ChannelMembers
      include Cinch::Plugin

      set :required_options, [:database]

      listen_to :connect,    :method => :setup
      listen_to :disconnect, :method => :cleanup
      listen_to :join,       :method => :create_record
      listen_to :leaving,    :method => :create_record

      @db


      def setup(*)
        if File.exists?(config[:database])
          @db = SQLite3::Database.open(config[:database])
        else
          @bot.debug "Creating database: #{config[:database]}"
          @db = SQLite3::Database.new(config[:database])
          if @db
            @db.execute("
              CREATE TABLE ChannelMembers (
              'channel' VARCHAR(255),
              'count' INTEGER,
              'time' DATETIME
              );
            ")
          end
        end
      end

      def cleanup(*)
        @db.close
        bot.debug("Closed DB")
      end

      def create_record(msg,user=nil)
# TODO hardcoded channel name #greek as quit doesn't provide channel
        channel_name = "#greek"
        @db.execute( "INSERT into ChannelMembers (channel,count,time) VALUES ('#{channel_name}' , #{@bot.channels.select{|channel| channel.name == channel_name}[0].users.count}, '#{Time.now.to_s}');")
      end

      match /current_peak/, method: :announce_peak
      def announce_peak(msg)
# TODO hardcoded channel name #greek as quit doesn't provide channel
        channel_name = "#greek"
        if msg.channel.nil? or msg.channel.name == channel_name
          result = @db.execute("SELECT count,time FROM ChannelMembers WHERE channel = ? ORDER BY count DESC LIMIT 1", channel_name)[0]
          msg.reply "Current channel peak is #{result[0]} members on #{result[1]}"
        end
      end

    end
  end
end
