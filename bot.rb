require 'rubygems'
require 'cinch'
require 'yaml'
require './plugins/delicious_poster'

@bot = Cinch::Bot.new do
  settings = YAML::load(File.open("account.yml"))
  configure do |c|
    c.server = "#{settings["irc_settings"]["server"]}"
    c.nick = "#{settings["irc_settings"]["nick"]}"
    c.channels = ["##{settings["irc_settings"]["channel"]}"]
    c.plugins.plugins = [DeliciousPoster]
  end  
end

@bot.start
