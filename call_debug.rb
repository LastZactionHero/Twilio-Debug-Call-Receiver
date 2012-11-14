require 'rubygems'
require 'sinatra'
require "sinatra/reloader"
require 'sinatra/content_for'
require "sinatra/config_file"
require 'twilio-ruby'

# Load heroku vars from local file
heroku_env = File.join('heroku_env.rb')
load(heroku_env) if File.exists?(heroku_env)

get '/' do
  capability = Twilio::Util::Capability.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  capability.allow_client_incoming "client"
  token = capability.generate
  
  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  phone_numbers = client.account.incoming_phone_numbers.list.map{ |number| { 
        :sid => number.sid, 
        :phone_number => number.phone_number, 
        :voice_url => number.voice_url,
        :voice_method => number.voice_method,
        :sms_url => number.sms_url,
        :sms_method => number.sms_method,
        :status_callback => number.status_callback,
        :status_callback_method => number.status_callback_method } }
  
  erb :index, :locals => {:token => token, :phone_numbers => phone_numbers }
end

get '/twilio/incoming' do
  Twilio::TwiML::Response.new { |r| r.Dial { |d| d.Client "client" } }.text
end
 