class Connectors::WarehouseConnector
  class InvalidConfigurationException < Exception
  end

  def initialize
    @server_address = ENV["WAREHOUSE_ADDRESS"]
    @conn = Faraday.new(:url => @server_address) do |faraday|
      faraday.request :json
      faraday.response :logger   
      faraday.response :json, :content_type => "application/json"               
      faraday.adapter  Faraday.default_adapter  
    end
  end
  def get(options={})
    Rails.logger.info "Attempting to GET to #{@server_address}#{options[:path]}"
    Rails.logger.info "Attempting to GET with headers #{options[:headers]}"
    response = @conn.get do |req|                           
        req.url options[:path]
        req.params = options[:params] unless options[:params].nil?
        req.headers["Authorization"] = options[:headers] unless options[:headers].nil?
    end
    JSON.parse response.body.to_json if response.status < 300
  end
  def post(options={})
    Rails.logger.info "Attempting to POST to #{@server_address}#{path}"
    response = @conn.post do |req|
        req.url options[:path]
        req.body = options[:body].to_json unless options[:body].nil?
        req.headers["Authorization"] = options[:headers] unless options[:headers].nil?
      end
      JSON.parse response.body.to_json if response.status < 300
  end
  def getAlmacenes()
    options = {
      :path => "/almacenes",
      :headers => generate_security_header("get")
    }
    get options
  end
  def getSkusWithStock(almacen_id)
    options = {
      :path => "/almacenes",
      :headers => generate_security_header("post", params)
    }
    get options
  end
  def generate_security_header(http_method, params={})
    require 'digest/hmac'
    header = http_method.to_s.upcase
    Rails.logger.info "Header Method: #{header}"
    params.each do |key,value|
      Rails.logger.info "Param: #{key} => #{value}"
      header += value.to_s
    end
    #hmac_header = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), "acbd12345", header)
    #encoded_header = Base64.encode64(hmac_header)
    
    #encoded_header = CGI.escape(Base64.encode64("#{OpenSSL::HMAC.digest('sha1', ENV["WAREHOUSE_PRIVATE_KEY"] , header)}"))
    
    #encoded_header = hmac_sha1(header)

    #hmac = HMAC::SHA1.new("acbd12345")
    #hmac.update(header)
    #encoded_header = CGI.escape(Base64.encode64("#{hmac.digest}\n"))
    Rails.logger.info "Pre encoded Header: #{header}"
    encoded_header = Base64.encode64(Digest::HMAC.digest(header, ENV["WAREHOUSE_PRIVATE_KEY"], Digest::SHA1))

    Rails.logger.info "Header: #{encoded_header}"
    complete_header = "UC grupo8:"+encoded_header
    Rails.logger.info complete_header
    complete_header
  end  
end