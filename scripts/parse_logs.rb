#!/bin/env ruby

require 'sqlite3'
require 'time'

db_filename = "var/log_entries.db"

log_entries = open("var/cinch.log").read.split("\n")

privmsg_match = /\[(.*)\] .. :(.*)!(.*) PRIVMSG (.*) :(.*)/
ban_match = /\[(.*)\] .. :(.*)!.* MODE (.*) \+b (.*) /
kick_match = /\[(.*)\] .. :(.*)!.* KICK (#\w+) (\w+) :(.*)/

privmsgs = log_entries.select{|entry| entry.match(privmsg_match)}
bans = log_entries.select{|entry| entry.match(ban_match)}
kicks = log_entries.select{|entry| entry.match(kick_match)}

if File.exists?(db_filename)
  db = SQLite3::Database.open(db_filename)
else
  db = SQLite3::Database.new(db_filename)
end

db.execute("
  CREATE TABLE IF NOT EXISTS LastEntry (
    'db' VARCHAR(255),
    'time' VARCHAR(255)
  );
")

db.execute("
  CREATE TABLE IF NOT EXISTS PrvMsg (
    'nick' VARCHAR(255),
    'hostmask' VARCHAR(255),
    'target' VARCHAR(255),
    'message' VARCHAR(255),
    'time' DATETIME
  );
")

db.execute("
  CREATE TABLE IF NOT EXISTS Ban (
    'nick' VARCHAR(255),
    'channel' VARCHAR(255),
    'target' VARCHAR(255),
    'time' DATETIME
  );
")

db.execute("
  CREATE TABLE IF NOT EXISTS Kick (
    'nick' VARCHAR(255),
    'channel' VARCHAR(255),
    'target' VARCHAR(255),
    'reason' VARCHAR(255),
    'time' DATETIME
  );
")


last_privmsg = db.execute( "SELECT time FROM LastEntry WHERE db = 'PrvMsg' LIMIT 1")[0]
if last_privmsg.nil? 
  last_privmsg = "1970-01-01"
else 
  last_privmsg = last_privmsg[0]
end

last_ban = db.execute( "SELECT time FROM LastEntry WHERE db = 'Ban' LIMIT 1")[0]
if last_ban.nil? 
  last_ban = "1970-01-01"
else 
  last_ban = last_ban[0]
end

last_kick = db.execute( "SELECT time FROM LastEntry WHERE db = 'Kick' LIMIT 1")[0]
if last_kick.nil? 
  last_kick = "1970-01-01"
else 
  last_kick = last_kick[0]
end

privmsgs.each {|privmsg|
  parsed_message = privmsg.match(privmsg_match)
  if Time.parse(parsed_message[1]) > Time.parse(last_privmsg);
    last_privmsg = parsed_message[1]
    db.execute( "INSERT INTO PrvMsg (time,nick,hostmask,target,message) VALUES (?,?,?,?,?);", Time.parse(parsed_message[1]).to_s, parsed_message[2], parsed_message[3], parsed_message[4], parsed_message[5])
  end
}

db.execute("DELETE FROM LastEntry WHERE db = 'PrvMsg'");
db.execute("INSERT INTO LastEntry (db,time) VALUES (?,?)","PrvMsg",last_privmsg) if !last_privmsg.empty?

bans.each {|ban|
  parsed_message = ban.match(ban_match)
  if Time.parse(parsed_message[1]) > Time.parse(last_ban);
    last_ban = parsed_message[1]
    db.execute( "INSERT INTO Ban (time,nick,channel,target) VALUES (?,?,?,?);", Time.parse(parsed_message[1]).to_s, parsed_message[2], parsed_message[3], parsed_message[4])
  end
}

db.execute("DELETE FROM LastEntry WHERE db = 'Ban'");
db.execute("INSERT INTO LastEntry (db,time) VALUES (?,?)","Ban",last_ban) if !last_ban.empty?

kicks.each {|kick|
  parsed_message = kick.match(kick_match)
  if Time.parse(parsed_message[1]) > Time.parse(last_kick);
    last_kick = parsed_message[1]
    db.execute( "INSERT INTO Kick (time,nick,channel,target,reason) VALUES (?,?,?,?,?);", Time.parse(parsed_message[1]).to_s, parsed_message[2], parsed_message[3], parsed_message[4], parsed_message[5])
  end
}

db.execute("DELETE FROM LastEntry WHERE db = 'Kick'");
db.execute("INSERT INTO LastEntry (db,time) VALUES (?,?)","Kick",last_kick) if !last_kick.empty?

db.close
