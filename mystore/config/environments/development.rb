Mystore::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  ENV["WAREHOUSE_ADDRESS"] = "http://bodega-integracion-2014.herokuapp.com"
  ENV["WAREHOUSE_PRIVATE_KEY"] = "1PIohML3"
  #ENV["NOMBRE_SPREADSHEET"] = "ReservasG8Testing"

  #------IDS de Almacenes de la Bodega
  ENV["ALMACEN_RECEPCION"] = "53571e21682f95b80b78107d"
  ENV["ALMACEN_DESPACHO"] = "53571e21682f95b80b78107e"
  ENV["ALMACEN_PULMON"] = "53571e29682f95b80b786eb8"
  ENV["ALMACEN_LIBRE_DISPOSICION"] = "53571e21682f95b80b78107f"
  ENV["ALMACEN_X"] = "53571e29682f95b80b786eb7"

  #-----Password para comunicarse con las otras bodegas
  ENV["API_PASSWORD"] = "integramaster"
end
