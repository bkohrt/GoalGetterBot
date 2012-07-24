require "savon"

class ComunioService 
  def initialize
    @client = Savon.client("http://www.comunio.de/soapservice.php?wsdl")
  end
  
  def getClubs
    begin
      response = @client.request :getclubs
      response ? response.to_hash[:getclubs_response][:return][:item] : nil
    rescue
      nil
    end
  end
  
  def getPlayersOfClub id
    begin
      response = @client.request :getplayersbyclubid do
        soap.body = {id: id}
      end
      response ? response.to_hash[:getplayersbyclubid_response][:return][:item] : nil
    rescue
      nil
    end
  end
  
  def getPlayer id
    begin
      response = @client.request :getplayerbyid do
        soap.body = {id: id}
      end
      if response
        hash = response.to_hash[:getplayerbyid_response][:return][:item]
        player = Hash.new
        hash.each do | attr|
          player[attr[:key]] = attr[:value]
        end
        player
      else
        nil
      end
    rescue
      nil
    end
  end
end