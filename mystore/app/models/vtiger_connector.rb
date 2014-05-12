class VtigerConnector < Connectors::BaseConnector

  def ininitialize
    access_key = '9Q7SnRuMMZz6ZVP2'
    url = 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?'

    challenge = JSON.parse(open("#{url}operation=getchallenge&username=grupo8").read)
    token = challenge["result"]["token"]

    @response = RestClient.post( url , { 
      'operation'=>'login', 
      'username' => 'grupo8', 
      'accessKey' => Digest::MD5.hexdigest("#{token}#{access_key}")   
    })
  end

  def get_address(client_id)
    
  end

#####TEMP#####
  def data
    contact_query = URI.encode("SELECT * FROM contacts LIMIT 10;")
    session_id = JSON.parse(@response)["result"]["sessionName"]
    @contactos = RestClient.get( url , {
      'operation' => 'query',
      'sessionName' => session_id,
      'query' => contact_query
    })
  end
end