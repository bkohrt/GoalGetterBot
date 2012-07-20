require 'net/http'
require 'json'
require_relative "result_calculator"

bot_token = "fwo9yv49o7sw74kjupgi3egv"

url = "http://botliga.de/api/matches/2012"
response = Net::HTTP.get_response(URI.parse(url))
matches = JSON.parse(response.body)

http = Net::HTTP.new('botliga.de',80)
calculator = ResultCalculator.new

matches.each do |match|
  result = calculator.matchResult match['hostName'], match['guestName']
  puts "#{match['hostName']} - #{match['guestName']} #{result[0]}:#{result[1]}"
  #response, data = http.post('/api/guess',"match_id=#{match['id']}&result=#{result[0]}:#{result[1]}&token=#{bot_token}")
  
  # "201 Created" (initial guess) or "200 OK" (guess update)
  #puts "#{response.code} #{data}" 
end