#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'nokogiri'
require 'yaml'
require 'optparse'
require 'awesome_print'
require 'pry'

options = {}
op = OptionParser.new do |opts|
  opts.banner = "Usage: cars-hofman.rb [options]"
  options[:print_all] = false
  options[:limit] = Float::INFINITY
  opts.on("-c file", "--cache file", "Cache file location") do |c|
    options[:cache] = c
  end
  opts.on("-a", "--[no-]all", "Display all announces") do |a|
    options[:print_all] = a
  end
  opts.on("-i", "--[no-]interactive", "Launch interactive session") do |i|
    options[:interactive] = i
  end
  opts.on("-l", "--limit=value", Float, "Show cars cheaper than",) do |l|
    options[:limit] = l
  end
end

begin op.parse! ARGV
rescue OptionParser::ParseError => e
  puts e
  puts op
  exit 1
end

@cache = options[:cache].nil? ? File.dirname(__FILE__) + "/.#{File.basename($0,'.rb')}.cars.cache" : options[:cache]
begin
  @cars = YAML::load(File.open(@cache))
  @cars = [] unless @cars.is_a?(Array)   # Be sure file is not corrupted
  @cars.select { |j| j[:new] }.each { |x| x.delete(:new) }
rescue Errno::ENOENT
  @cars = []
end
#https://www.hofman.nl/aanbod/?sorteer_op=prijs&pagina=2
@url = "https://www.hofman.nl/aanbod/"

current_price = 0
i = 1

while current_price <= options[:limit] 
  uri = URI.parse("#{@url}?sorteer_op=prijs&pagina=#{i}")
  
  request = Net::HTTP::Get.new(uri)
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end
  
  html_doc = Nokogiri::HTML(response.body)

  html_doc.css("div.inventory").each do |c|
    car = {
      name: c.css(".title").text,
      #scrub to avoid error with invalid encoding
      model: c.css(".spec").map(&:text).join(" ").scrub,
      link: c.css("a").attribute('href').text,
      price: c.css(".figure").text.sub(/€/,'').strip.to_i
    }
    current_price = car[:price]
    car[:new] = true unless @cars.include?(car)
    @cars << car
    break if current_price > options[:limit]
  end
  break if i == html_doc.css(".pagination li")[-2].text.to_i
  i+=1
end

if options[:print_all]
  ap @cars
else
  ap @cars.select { |x| x[:new] }
end

File.open(@cache, 'w') { |f| f.write(YAML.dump(@cars)) }

Pry.start if options[:interactive]