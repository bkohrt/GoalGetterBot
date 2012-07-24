#encoding: utf-8

require "savon"

class ComunioService 
  def initialize
    @client = Savon.client("http://www.comunio.de/soapservice.php?wsdl")
    @client.config.log = false
    HTTPI.log = false
  end
  
  def clubs
    begin
      response = @client.request :getclubs
      response.success? ? response.to_hash[:getclubs_response][:return][:item] : nil
    rescue
      nil
    end
  end
  
  def playersOfClub id
    begin
      response = @client.request :getplayersbyclubid do
        soap.body = {id: id}
      end
      response.success? ? response.to_hash[:getplayersbyclubid_response][:return][:item] : nil
    rescue
      puts "Üngültige Vereins ID"
      nil
    end
  end
  
  def player id
    begin
      response = @client.request :getplayerbyid do
        soap.body = {id: id}
      end
      return nil unless response.success?
      response_hash = response.to_hash[:getplayerbyid_response][:return][:item]
      response_hash.inject(Hash.new) do |player, attr|
        player[attr[:key]] = attr[:value]
        player
      end
    rescue
      puts "Ungültige Spieler ID"
      nil
    end
  end
end