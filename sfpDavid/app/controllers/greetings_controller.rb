class GreetingsController < ApplicationController

  

  def hello
  	
	Net::SFTP.start('integra.ing.puc.cl', 'grupo8', :password => 's3932ko') do |sftp|
		#@otra = ""
		@message = ""
		sftp.dir.entries('/home/grupo8/Pedidos').each do |remote_file|
      		file_data = sftp.download!('/home/grupo8/Pedidos/' + remote_file.name)
      		#local_file = File.open('/Users/David/Desktop/sftp/'+ remote_file.name, 'wb')
      		#local_file.print file_data
      		#local_file.close
      		#@otra = @otra << "\n" <<remote_file.name
      		@message = @message << file_data
		end
	end

	

   #  sftp = Net::SFTP.start('integra.ing.puc.cl', 'grupo8', :password => 's3932ko') # I've got a session object so that seems to work
   #  # upload a file or directory to the remote host
   #  sftp.file.open("/home/grupo8/Pedidos/pedido_634.xml", "r") do |f|
   
  	# @message = f.gets

  	end

  	#def read_xml()

end
