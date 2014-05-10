require 'httparty'
require 'rest_client'

class ApiTestController < ApplicationController

	def index
		access_key = '9Q7SnRuMMZz6ZVP2'
	
		challenge = JSON.parse(open('http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=getchallenge&username=grupo8').read)
		token = challenge["result"]["token"]

		@response = RestClient.post('http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=login', {	
			'username' => 'grupo8',	'accessKey' => Digest::MD5.hexdigest("#{token}#{access_key}")		
		})
		#login = JSON.parse(open('http://integra.ing.puc.cl/vtigerCRM/webservice.php?operation=login&username=grupo8&accessKey=' + Digest::MD5.hexdigest(access_key + token)).read)
	end
end