require 'net/http'
require 'json'

require_relative "./lib/result_calculator"

bot_token = "fwo9yv49o7sw74kjupgi3egv"

url = "http://botliga.de/api/matches/2012"
response = Net::HTTP.get_response(URI.parse(url))
matches = JSON.parse(response.body)

http = Net::HTTP.new('botliga.de',80)
calculator = ResultCalculator.new

matches.each do |match|
  if match['hostGoals'].nil?
    result = calculator.matchResult match['hostName'], match['guestName']
    #puts "#{match['hostName']} - #{match['guestName']} #{result[0]}:#{result[1]}"
    response, data = http.post('/api/guess',"match_id=#{match['id']}&result=#{result[0]}:#{result[1]}&token=#{bot_token}")
  
    puts "#{response.code} #{data}" 
  end
end
