#!/usr/bin/env ruby
#./traveling/bin/ruby
require 'open-uri'
require 'nokogiri'

doc = Nokogiri::HTML(open('https://www.lollaparis.com/tickets/'))
if doc.css('a.btn').length != 4
  puts 'new stuff'
  %x(osascript -e 'display notification "there is new tickets !!!" with title "Lollapalooza"')
  doc.css('a.btn').each do |x|
    %x(osascript -e 'display notification "#{x.content}" with title "Lollapalooza"')
    puts x.content
  end
else
  puts 'nothing new'
end

