#!/usr/bin/env ruby
require 'rest-client'
require 'json'
require 'yaml/store'
require 'date'

DEBUG = false

require 'awesome_print' if DEBUG

store = YAML::Store.new "store.yaml.cache"

@params = {
  grant_type: 'password',
  client_id: ENV['CLIENT_ID'],
  client_secret: ENV['CLIENT_SECRET'],
  username: ENV['USER_MAIL'],
  password: ENV['USER_PASSWORD'],
  scope: 'read_thermostat'
}

def pd x
  ap x if DEBUG
end

def get_netatmo_token
  begin
    response = RestClient.post 'https://api.netatmo.com/oauth2/token', @params
  rescue RestClient::ExceptionWithResponse => e
    puts e
  end
  pd JSON.parse(response.body)
  JSON.parse(response.body)
end

def get_netatmo_thermostat token
  begin
    response = RestClient.post 'https://api.netatmo.com/api/getthermostatsdata', token
  rescue RestClient::ExceptionWithResponse => e
    puts e
  end
  pd JSON.parse(response.body)
  JSON.parse(response.body)
end

def get_netatmo_data params
  begin
    response = RestClient.post 'https://api.netatmo.com/api/getmeasure', params
  rescue RestClient::ExceptionWithResponse => e
    puts e
  end
  pd JSON.parse(response.body)
  JSON.parse(response.body)
end

store.transaction do 
  if store[:access_token].nil? || Time.now.to_i > store[:expires_in]
    puts store
    exit 
    token = get_netatmo_token
    store[:access_token] = token['access_token']
    store[:expires_in] = Time.now.to_i + token['expires_in'] - 30
  end
  params = { access_token: store[:access_token] }
  data = get_netatmo_thermostat params 
  data['body']['devices'].each do |d|
    params[:device_id] = d['_id'] 
    d['modules'].each do |m|
      params[:module_id] = m['_id']
      params[:date_begin] = store[:last_ts] unless store[:last_ts].nil?
      params[:scale] = 'max'
      params[:type] = 'temperature,sp_temperature,boileron'
      ts = get_netatmo_data params
      store[:last_ts] = ts['body'].last.values_at('beg_time').first
      p ts
    end
  end
end
