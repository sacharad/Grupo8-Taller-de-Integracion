class Connectors::TwitterConnector
	OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


	def self.twitter_client
		  	@twitter_client ||= Twitter::REST::Client.new do |config|
		  	config.consumer_key        = "hsHvWEhpi5FDZnOmr9pgznnIJ"
		  	config.consumer_secret     = "RRCl5otfxwugwFwWSTEh4mc3dLSpkRJjd69xLPTLi0QUN6n9Sc"
		  	config.access_token        = "2550898645-QBZpelMrknTX2b2CfD4ubqlnu5eRyziSrbu1SSl"
		  	config.access_token_secret = "4hA31N9TXztLl0Q7I13itgtol21aCGIrIXQTfbb2jUWj9"
		  	end
		@twitter_client
	end

	def self.enviarMensaje(mensaje)
			twitter_client.update(mensaje)
	end

	def self.listTwits
			twitter_client.user_timeline
	end
end
