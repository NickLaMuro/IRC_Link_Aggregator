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
    description = doc.css("h2~p").first if item.description.nil?
    description = doc.css("article p").first if item.description.nil?
    description = doc.css("#content p").first if item.description.nil?
    description = item.description.nil? ? "- None -" : item.description.content

    response = open("http://#{self.delicious_settings[:delicious_settings][:username]}:#{self.delicious_settings[:delicious_settings][:password}@api.del.icio.us/v4/posts/add?&url=#{link}&description=#{title}&extended=#{description}&tags=webdev&shared=no&replace=no")

    puts response

  end

end
