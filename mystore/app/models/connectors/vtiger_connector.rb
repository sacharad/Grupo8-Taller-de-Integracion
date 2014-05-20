require 'uri'

class Connectors::VtigerConnector

  def initialize
    access_key = '9Q7SnRuMMZz6ZVP2'
    @url = 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?'

    challenge = JSON.parse(open("#{@url}operation=getchallenge&username=grupo8").read)
    token = challenge["result"]["token"]

    response = RestClient.post( @url , { 
      'operation'=> 'login', 
      'username' => 'grupo8', 
      'accessKey' => Digest::MD5.hexdigest("#{token}#{access_key}")   
    })

    @session_id = JSON.parse(response)["result"]["sessionName"]
  end

  def getAddress(direccion_id)
    query = URI.encode("SELECT otherstreet, othercity, otherstate FROM Contacts WHERE cf_707 = '#{direccion_id}';")
    adds = RestClient.get("#{@url}operation=query&sessionName=#{@session_id}&query=#{query}")

    address = JSON.parse(adds)["result"][0]
    return "calle: #{address["otherstreet"]} - ciudad: #{address["othercity"]} - region: #{address["otherstate"]}"
  end

  def checkClient(direccion_id, rut_cliente)
    return true
  end
end