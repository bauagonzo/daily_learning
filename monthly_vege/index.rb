#!/usr/bin/env ruby
require_relative './bundler/setup'
require 'open-uri'
require 'nokogiri'
require 'gmail'

def main(event, context)
  queryparams = event["query"]
  body = event["body"]
  doc = Nokogiri::HTML(open('https://www.fruits-legumes.org/'))

  Gmail.connect(ENV['GMAIL'], ENV['GMAILPASS']) do |gmail|
    xx = gmail.compose do
      to ENV['GMAILDEST']
      subject doc.at_css('#contenu h1').content 
      html_part do
        content_type 'text/html; charset=UTF-8'
        body doc.at_css('#fruit-legume').inner_html
      end
    end
    xx.deliver!
  end

  {
    :statusCode => 200,
    :body => "{'hello':'from Ruby2.4.1 function #{event["query"]}'}"
  }
end
