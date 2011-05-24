require 'rubygems'
require 'cinch'
require 'yaml'
require './plugins/delicious_poster'
require './plugins/link_catcher'

@bot = Cinch::Bot.new do
  settings = YAML::load(File.open("irc.yml"))
  configure do |c|
    c.server = "#{settings[:irc_settings][:server]}"
    c.nick = "#{settings[:irc_settings][:bot_name]}"
    c.channels = ["##{settings[:irc_settings][:channel]}"]
    c.plugins.plugins = [LinkCatcher, DeliciousPoster]
  end  
end

@bot.start
