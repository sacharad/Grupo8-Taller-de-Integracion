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
    if direccion_id.nil?
      Rails.logger.info 'ERROR getAddress didnt receive valid direccion_id'
      Rails.logger.info 'class direccion_id: '+direccion_id.class.to_s
      Rails.logger.info 'direccion_id: '+direccion_id.to_s
      return nil
    end
    Rails.logger.info "Direccion Class: "+ direccion_id.class.to_s
    Rails.logger.info "Direccion: "+ direccion_id.to_s

    query = URI.encode("SELECT otherstreet, othercity, otherstate FROM Contacts WHERE cf_707 = '#{direccion_id}';")
    adds = RestClient.get("#{@url}operation=query&sessionName=#{@session_id}&query=#{query}")
    adds = JSON.parse adds
    
    if adds['success'] == false
      Rails.logger.info 'ERROR getAddress didnt receive valid vTiger Response'
      Rails.logger.info 'vTiger Response: '+adds.to_s
      return nil
    end

    Rails.logger.info "Query Class: "+ query.class.to_s
    Rails.logger.info "Query : "+ query.to_s
    Rails.logger.info "adds Class: "+ adds.class.to_s
    Rails.logger.info "adds: "+ adds.to_s
    if adds["result"].nil?
      Rails.logger.info 'ERROR getAddress didnt receive vTiger Response containig result json key'
    end

    address = adds["result"][0]
    return "#{address["otherstreet"]}, #{address["othercity"]}, #{address["otherstate"]}"
  end

  def checkClient(direccion_id, rut_cliente)
    return true
  end
end