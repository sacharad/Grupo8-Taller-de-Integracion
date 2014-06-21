
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron





#ejecuta metodo que lee reserva en spreadsheet y la ingresa a base de datos
set :output, 'tmp/whenever.log'

every 10.minute do
  runner "Product.vaciar_almacen_recepcion"
end

#Actualizar stock en almacenes
every 12.hours do
  runner "Product.actualizarAlmacenes"
end

#Actualización pricing
every :day, :at => '6am' do
  runner "Linkdropbox.download_and_load_prices"
end 

every 15.minutes do
 	runner "OrdersManager.fetchOrders" 
end

every 5.minutes do
 	runner "OrdersManager.fetchWeb" 
end

#Actualización nocturna de stock
every :day, :at => '1am' do
  runner "Product.asignar_stock"
end

#Promociones rabbit
every 30.minutes do
 	runner "Product.actualizar_precios" 
end

#Leer rabbit
every 1.hour do
 	runner "Rabbitmq.ofertas" 
end


# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

