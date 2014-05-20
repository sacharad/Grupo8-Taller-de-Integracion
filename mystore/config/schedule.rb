
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron





#ejecuta metodo que lee reserva en spreadsheet y la ingresa a base de datos
set :output, 'tmp/whenever.log'
every 1.minute do
  runner 'Reserve.log' , :environment => 'development'
  runner 'Reserve.log', :environment => 'production' 
end
# every 1.minute do
#   runner "Product.vaciar_almacen_recepcion"
# end

# every 10.minutes do
# 	runner "OrdersManager.fetchOrders" 
# end

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

