require 'rest_client'

class ApiTestController < ApplicationController

	def index
	    access_key = '9Q7SnRuMMZz6ZVP2'
	    url = 'http://integra.ing.puc.cl/vtigerCRM/webservice.php?'

	    challenge = JSON.parse(open("#{url}operation=getchallenge&username=grupo8").read)
	    token = challenge["result"]["token"]

	    @response = JSON.parse(RestClient.post( url , { 
	    	      'operation'=>'login', 
	    	      'username' => 'grupo8', 
	    	      'accessKey' => Digest::MD5.hexdigest("#{token}#{access_key}")   
	    	    }))

	    contact_query = URI.encode("SELECT * FROM Accounts;")
	    session_id = @response["result"]["sessionName"]
	    @contactos = RestClient.get( url , {
	    	'operation' => 'query',
	    	'sessionName' => session_id,
			'query' => contact_query
	    })
	    @c1 = RestClient.get( url , {
	    	'operation' => 'retrieve',
	    	'sessionName' => session_id,
			'id' => 'CON2748'
	    })
	end
end