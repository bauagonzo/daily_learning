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
  opts.banner = "Usage: careers-proservia.rb [options]"
  options[:print_all] = false
  opts.on("-c file", "--cache file", "Cache file location") do |c|
    options[:cache] = c
  end
  opts.on("-a", "--[no-]all", "Display all announces") do |a|
    options[:print_all] = a
  end
  opts.on("-i", "--[no-]interactive", "Launch interactive session") do |i|
    options[:interactive] = i
  end
end

begin op.parse! ARGV
rescue OptionParser::ParseError => e
  puts e
  puts op
  exit 1
end

@cache = options[:cache].nil? ? File.dirname(__FILE__) + "/.#{File.basename($0,'.rb')}.jobs.cache" : options[:cache]
begin
  @jobs = YAML::load(File.open(@cache))
  @jobs = [] unless @jobs.is_a?(Array)   # Be sure file is not corrupted
  @jobs.select { |j| j[:new] }.each { |x| x.delete(:new) }
rescue Errno::ENOENT
  @jobs = []
end

@url = "https://recrutement.proservia.fr/public/index.php"
uri = URI.parse("#{@url}?a=annonce")
request = Net::HTTP::Post.new(uri)
request.set_form_data(
  "a" => "annonce",
  "localisation[]" => "11570431072",
)

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
  http.request(request)
end

html_doc = Nokogiri::HTML(response.body)

html_doc.css(".listcv [class*='row']").each do |j|
  job=%i{date title location}.zip(j.css('td').map(&:text)).to_h
  job[:link] = "#{@url + j['onclick'][/(a=.*\d)/]}"
  job[:new] = true unless @jobs.include?(job)
  @jobs << job
end

if options[:print_all]
  ap @jobs
else
  ap @jobs.select { |x| x[:new] }
end

File.open(@cache, 'w') { |f| f.write(YAML.dump(@jobs)) }

Pry.start if options[:interactive]
