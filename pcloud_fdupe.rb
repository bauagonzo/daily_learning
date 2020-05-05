require 'httparty'
require 'json'

ENV['PCLOUD_USER'] ||= 'baua.gonzo@gmail.com'
ENV['PCLOUD_PASSWORD'] ||= ''
ENV['PCLOUD_DRYRUN'] ||= 'true'
class Pcloud
  include HTTParty
  base_uri 'https://api.pcloud.com/'
end

# something nil or empty means dir so skip it
def get_all_files(dir, path = '/', acc = Hash.new {|h,k| h[k] = [] })
   dir['contents'].each do |x|
    get_all_files(x,"#{path}/#{x['name']}", acc) unless x['contents'].nil? || x['contents'].empty?
    x['path'] = path
    acc[x['hash']] << x unless x['hash'].nil?
  end
  acc
end

user = Pcloud.get('/userinfo', query: {getauth: 1,username: ENV['PCLOUD_USER'], password: ENV['PCLOUD_PASSWORD']})
Pcloud.cookies(auth: user['auth'])
res = JSON.parse(Pcloud.get('/listfolder', query: {path: '/', recursive: 1}).response.body)

all_files = get_all_files(res['metadata'], res['metadata']['path'])

all_files.select {|k, v| v.size > 1}.each do |k,v|
  # keep the first file in the list
  # TODO give an option to select which file to keep or drop
  v.select { |f| f['path'] =~ /\/\/Automatic Upload\//}.each do |f|
    pp f
    Pcloud.get('/deletefile', query: {fileid: f['fileid']}) if ENV['PCLOUD_DRYRUN'] == 'false'
  end
end
