require "bundler/setup"
Bundler.require(:default)

require 'rubygems'
require 'sinatra'
require 'tropo-webapi-ruby'
require 'net/http'
require 'redis'
require 'os'
require 'json'
require 'resque'
require 'resque_scheduler'
require 'active_support/time'
require 'rest-client'
require 'mailgun'
require 'multimap'


# curl -X POST -d brian=awesome http://sharp-day-6988.heroku.com/getsession.json
# for local testing curl -X POST -d "{\"territory_name\":\"Hungry Buffs\",\"restaurant_phone_number\":\"1112223333\",\"order_number\":\"1232131\"}" http://localhost:9393/start.json
# curl -X POST -d "{\"territory_name\":\"HungryBuffs\",\"restaurant_phone_number\":\"4435270060\",\"order_number\":\"1232131\"}" http://phones.herokuapp.com/getsession.json

# or hurl post against: http://phones.herokuapp.com/getsession.json
# To ship, try ship!
# {"territory_name":"EatBeemore","restaurant_phone_number":"4435270060","order_number":"3582147"}
# {"territory_name":"EatBmore","restaurant_phone_number":"4435270060","order_number":"3582147", "order_type":"fax", "oder_total":"10"}


post '/start.json' do
  
  puts "start"
  token = "10611c9d5a24c241a517c8b6bb218beaa62779fc9511f333740f9fccda086d8d4a1432f038a75b992cd3b034"
  tropo_session_api = "api.tropo.com"
  tropo_path = "/1.0/sessions?action=create&token=#{token}"

  http = Net::HTTP.new tropo_session_api
  http.get tropo_path
end

post '/call1.json' do
  puts "call1"
  t = Tropo::Generator.new
  
  req_body = request.body.read
  json_params = JSON.parse(req_body)["session"]["parameters"]

  hash = json_params["hash"]  

  
  #phone = "+14108025604"
  phone = ""
  msg = "Hello"

    t.call(:to => phone, :from => "4433058652")
#    t.say(:value => "http://testtropo.herokuapp.com/music/jingle.mp3")
    t.ask(:name => 'digit', 
        :say => [
          {:value =>"http://testtropo.herokuapp.com/music/jingle.mp3"
          },
          {:value => "Press any number to confirm receipt of order number for details. If you did not receive an order, please call one eight hundred 689-6613. Goodbye ", :voice => "elizabeth"}],
        :choices => {:value => "[1 DIGIT]", :mode => "dtmf"})
  
  puts "before events"

  t.on(:event => 'error', :next => '/test/error')
  
  t.on(:event => 'continue', :next => '/test/continue')
  
  puts "after events"
  
  t.response
end

post '/test/error' do
  puts "inside error"
end

post '/test/continue' do
  puts "inside continue"
end
