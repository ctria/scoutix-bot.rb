#!/bin/env ruby

require 'sqlite3'
require 'gruff'
require 'time'

StartOfJOTI = "2015-10-16 15:00:00 +0300"
EndOfJOTI = "2015-10-19 03:00:00 +0300"
Channel = "#" + ARGV[0]
TimeStep = 1800
OutputDir = "var/graphs/" + ARGV[0]

TimeLabels = {
  1445007600 => "Fri 18:00",
#  1445018400 => "Fri 21:00",
  1445029200 => "Sat 00:00",
#  1445040000 => "Sat 03:00",
  1445050800 => "Sat 06:00",
#  1445061600 => "Sat 09:00",
  1445072400 => "Sat 12:00",
#  1445083200 => "Sat 15:00",
  1445094000 => "Sat 18:00",
#  1445104800 => "Sat 21:00",
  1445115600 => "Sun 00:00",
#  1445126400 => "Sun 03:00",
  1445137200 => "Sun 06:00",
#  1445148000 => "Sun 09:00",
  1445158800 => "Sun 12:00",
#  1445169600 => "Sun 15:00",
  1445180400 => "Sun 18:00",
#  1445191200 => "Sun 21:00",
  1445202000 => "Mon 00:00",
#  1445212800 => "Mon 03:00",
}

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
g.marker_font_size = 13
g.labels = TimeLabels
g.hide_dots =true

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
g.labels = TimeLabels
g.marker_font_size = 13

g.write(OutputDir + "/privmsgs.png")
