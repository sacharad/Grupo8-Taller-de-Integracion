require 'uri'

class VtigerConnector

  def initialize
    access_key = '9Q7SnRuMMZz6ZVP2'
    @url = 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?'

    challenge = JSON.parse(open("#{@url}operation=getchallenge&username=grupo8").read)
    token = challenge["result"]["token"]

    response = RestClient.post( @url , { 
      'operation'=>'login', 
      'username' => 'grupo8', 
      'accessKey' => Digest::MD5.hexdigest("#{token}#{access_key}")   
    })

    @session_id = JSON.parse(response)["result"]["sessionName"]
  end

  def get_address(client_cf_705)
    query = URI.encode("SELECT bill_street, bill_city, bill_state FROM Accounts WHERE cf_705 = '#{client_cf_705}';")
    address = RestClient.get("#{@url}operation=query&sessionName=#{@session_id}&query=#{query}")
  end
end