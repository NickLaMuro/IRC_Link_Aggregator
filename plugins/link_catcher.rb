require 'nokogiri'
require 'open-uri'
require 'cinch'
require 'tumblr'
require 'yaml'

class String
  # turns a string into a title by capitalizing each word
  def titleize
    self.split(/ /).collect{|w| w.capitalize}.join(' ')
  end
end

class LinkCatcher
  include Cinch::Plugin
  
  attr_accessor :tumblr_settings
  
  def initialize(*args)
    super
    self.tumblr_settings = YAML::load(File.open("account.yml"))
  end
  
  listen_to :channel
  
  def listen(m)
    urls = URI.extract(m.message, ["http", "https"])
    unless urls.empty?
      urls.each do |url|
        write(url, m)
      end
    end
  end
  
  def write(link, m)
    doc = Nokogiri::HTML(open(link))
    
    item = Tumblr.parse(link)
    
    if item.is_a? Tumblr::Post::Link
      # for links, set the title and description
      item.title = doc.css("title").first.content
      
      # hierarchy of where to look
      item.description = doc.css("h1~p").first
      item.description = doc.css("h2~p").first if item.description.nil?
      item.description = doc.css("article p").first if item.description.nil?
      item.description = doc.css("#content p").first if item.description.nil?
      item.description = item.description.nil? ? "No description found." : item.description.content
    elsif item.is_a? Tumblr::Post::Video
      item.caption = doc.css("meta[name=description]").first.attribute("content")
    end
    
    request = Tumblr.new(self.tumblr_settings[:tumblr_settings][:email], self.tumblr_settings[:tumblr_settings][:password]).post(item)
    request.perform do |response|
      unless response.success?
        m.reply "There was a problem posting to tumblr."
      end
    end
  end
end
