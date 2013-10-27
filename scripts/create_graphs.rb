#!/bin/env ruby

require 'sqlite3'
require 'gruff'
require 'time'

StartOfJOTI = "2013-10-18 18:00:00 +0300"
EndOfJOTI = "2013-10-21 03:00:00 +0300"
Channel = "#greek"
TimeStep = 1800
OutputDir = "var/graphs"

db = SQLite3::Database.open('var/channel_members.db')
datasets = db.execute('SELECT time,count FROM ChannelMembers WHERE Channel = ? AND time >= ? AND time <= ? ORDER BY time', Channel, Time.parse(StartOfJOTI).to_s, Time.parse(EndOfJOTI).to_s)
db.close

db = SQLite3::Database.open('var/log_entries.db')
prvmsgs = db.execute('SELECT * FROM PrvMsg WHERE target = ? AND time >= ? AND time <= ? ORDER BY time', Channel, Time.parse(StartOfJOTI).to_s, Time.parse(EndOfJOTI).to_s)
bans = db.execute('SELECT * FROM Ban WHERE Channel = ? AND time >= ? AND time <= ? ORDER BY time', Channel, Time.parse(StartOfJOTI).to_s, Time.parse(EndOfJOTI).to_s)
kicks = db.execute('SELECT * FROM Kick WHERE Channel = ? AND time >= ? AND time <= ? ORDER BY time', Channel, Time.parse(StartOfJOTI).to_s, Time.parse(EndOfJOTI).to_s)
db.close

g = Gruff::Line.new
g.dataxy("Members in the #{Channel} channel",datasets.collect{|data| Time.parse(data[0]).to_i},datasets.collect{|data| data[1]})

g.labels = {
  1382130000 => "Sat 00:00",
#  1382140800 => "Sat 03:00",
#  1382151600 => "Sat 06:00",
#  1382162400 => "Sat 09:00",
  1382173200 => "Sat 12:00",
#  1382184000 => "Sat 15:00",
#  1382194800 => "Sat 18:00",
#  1382205600 => "Sat 21:00",
  1382216400 => "Sun 00:00",
#  1382227200 => "Sun 03:00",
#  1382238000 => "Sun 06:00",
#  1382248800 => "Sun 09:00",
  1382259600 => "Sun 12:00",
#  1382270400 => "Sun 15:00",
#  1382281200 => "Sun 18:00",
#  1382292000 => "Sun 21:00",
  1382302800 => "Mon 00:00",
}
g.write(OutputDir + '/channel_members.png')

g = Gruff::Pie.new
g.title = "#{bans.count} bans during the JOTI period"
g.add_color("red")
g.add_color("blue")
g.add_color("grey")
g.add_color("green")
bans.collect{|ban| ban[0].downcase}.uniq.each{|operator| 
  g.data operator, bans.select{|ban| ban[0].downcase == operator}.count
}
g.write(OutputDir + "/bans.png")

g = Gruff::Pie.new
g.title = "#{kicks.count} kicks during the JOTI period"
g.add_color("red")
g.add_color("blue")
g.add_color("grey")
g.add_color("green")
kicks.collect{|kick| kick[0].downcase}.uniq.each{|operator| 
  g.data operator, kicks.select{|kick| kick[0].downcase == operator}.count
}
g.write(OutputDir + "/kicks.png")


datasets=[]
time = Time.parse(StartOfJOTI).to_i 
while time < Time.parse(EndOfJOTI).to_i
  datasets << [time,prvmsgs.select{|privmsg| Time.parse(privmsg[4]).to_i >= time && Time.parse(privmsg[4]).to_i < time + TimeStep}.count]
  time += TimeStep
end
g = Gruff::Line.new
g.title = "#{prvmsgs.count} messages in the channel"
g.hide_dots =true
g.dataxy("Messages sent in the #{Channel} channel per 30 minutes",datasets.collect{|data| data[0]},datasets.collect{|data| data[1]})
g.labels = {
  1382130000 => "Sat 00:00",
#  1382140800 => "Sat 03:00",
#  1382151600 => "Sat 06:00",
#  1382162400 => "Sat 09:00",
  1382173200 => "Sat 12:00",
#  1382184000 => "Sat 15:00",
#  1382194800 => "Sat 18:00",
#  1382205600 => "Sat 21:00",
  1382216400 => "Sun 00:00",
#  1382227200 => "Sun 03:00",
#  1382238000 => "Sun 06:00",
#  1382248800 => "Sun 09:00",
  1382259600 => "Sun 12:00",
#  1382270400 => "Sun 15:00",
#  1382281200 => "Sun 18:00",
#  1382292000 => "Sun 21:00",
  1382302800 => "Mon 00:00",
}
g.write(OutputDir + "/privmsgs.png")
