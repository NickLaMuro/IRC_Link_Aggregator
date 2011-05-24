require 'nokogiri'
require 'open-uri'
require 'cinch'
require 'yaml'

class String
  # turns a string into a title by capitalizing each word
  def titleize
    self.split(/ /).collect{|w| w.capitalize}.join(' ')
  end
end

class DeliciousPoster
  include Cinch::Plugin
  
  attr_accessor :delicious_settings
  
  def initialize(*args)
    super
    self.delicious_settings = YAML::load(File.open("account.yml"))
  end
  
  listen_to :channel
  
  def listen(m)
    urls = URI.extract(m.message, ["http", "https"])
    unless urls.empty?
      urls.each do |url|
        write(url)
      end
    end
  end
  
  def write(link)
    doc = Nokogiri::HTML(open(link))

    title = doc.css("title").first.content

    # hierarchy of where to look
    description = doc.css("h1~p").first
    description = doc.css("h2~p").first if description.nil?
    description = doc.css("article p").first if description.nil?
    description = doc.css("#content p").first if description.nil?
    description = description.nil? ? "- None -" : description.content

    user = self.delicious_settings["delicious_settings"]["username"]
    password = self.delicious_settings["delicious_settings"]["password"] 

    delicious_link = URI.escape link
    delicious_description = URI.escape title.strip
    delicious_extended = URI.escape description.strip 
    
    tags = URI.escape self.delicious_settings["delicious_settings"]["tags"].join(" ")
    shared = self.delicious_settings["delicious_settings"]["shared"] ? "yes" : "no"
    replace = self.delicious_settings["delicious_settings"]["replace"] ? "yes" : "no"

    uri = "https://#{user}:#{password}@api.del.icio.us/v1/posts/add?&url=#{delicious_link}&description=#{delicious_description}&extended=#{delicious_extended}&tags=#{tags}&shared=#{shared}&replace=#{replace}"

    response = `curl '#{uri}'` 
    puts response
  end

end
