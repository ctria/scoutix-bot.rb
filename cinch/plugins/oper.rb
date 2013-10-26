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
    class Oper 
      include Cinch::Plugin
    
      listen_to :connect, :method => :on_connect

      def on_connect(msg)
        bot.oper(config[:password], config[:username]) if config[:password]
      end
    end
  end
end
