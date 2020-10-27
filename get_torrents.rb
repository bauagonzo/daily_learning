#!/usr/bin/env ruby
require 'rest-client'
require 'uri'
require 'json'
require 'tempfile'
require 'resolv-replace'

ENV['MOVIE_IMDB'] ||= '0397306'
ENV['MOVIE_PATTERN_NAME'] ||= 'S16.*720.*AMZN'
URL = 'https://eztv.io/api/get-torrents'

dns_entries = JSON.parse(RestClient.get("https://cloudflare-dns.com/dns-query?name=#{URI.parse(URL).host}", 
                                        { accept: 'application/dns-json' }).body)

dns_file = Tempfile.new('dns')

dns_entries['Answer'].each do |dns|
    #print "#{dns['data']} #{dns['name']}\n"
    dns_file.write("#{dns['data']}\t#{dns['name']}\n")
end
dns_file.rewind

hosts_resolver = Resolv::Hosts.new(dns_file.path)
dns_resolver = Resolv::DNS.new

Resolv::DefaultResolver.replace_resolvers([hosts_resolver, dns_resolver])

def get_magnet_url(params = {}, filter = '.*', outputs = ['magnet_url'])
    total_page, current_page = nil
    while total_page.nil? || current_page < total_page do
        res = JSON.parse(RestClient.get(URL, 
                                        params: params).body,
                                        verify_ssl: false)
        total_page  ||= res['torrents_count'] / res['limit']
        current_page = res['page']  
        res['torrents'].each do |t|
          if t['title'] =~ /#{filter}/
                outputs.each do |o|
                    puts t[o]
                end
            end
        end
        params[:page] = current_page + 1
    end 
end

#puts get_magnet_url({imdb_id: '0397306'}, 'S16.*720.*AMZN', ['title','magnet_url'])
puts get_magnet_url({imdb_id: ENV['MOVIE_IMDB'] }, ENV['MOVIE_PATTERN_NAME'])
