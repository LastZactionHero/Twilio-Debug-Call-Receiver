require 'rubygems'
require 'sinatra'
require "sinatra/reloader"
require 'sinatra/content_for'
require "sinatra/config_file"
require 'twilio-ruby'

config_file 'settings.yml'

get '/' do
  capability = Twilio::Util::Capability.new settings.twilio_account_sid, settings.twilio_auth_token
  capability.allow_client_incoming settings.twilio_client_name  
  token = capability.generate
  
  client = Twilio::REST::Client.new settings.twilio_account_sid, settings.twilio_auth_token
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
  Twilio::TwiML::Response.new { |r| r.Dial { |d| d.Client settings.twilio_client_name } }.text
end
 