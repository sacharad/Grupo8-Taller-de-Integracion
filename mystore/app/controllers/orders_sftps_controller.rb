class OrdersSftpsController < ApplicationController
  before_action :set_orders_sftp, only: [:show, :edit, :update, :destroy]

  # GET /orders_sftps
  # GET /orders_sftps.json
  def index
    @sftp_connector = Connectors::SftpConnector.new
    @sftp_connector.getPedidosNuevos
    @orders_sftps = OrdersSftp.all
  end

  # GET /orders_sftps/1
  # GET /orders_sftps/1.json
  def show
  end

  # GET /orders_sftps/new
  def new
    @orders_sftp = OrdersSftp.new
  end

  # GET /orders_sftps/1/edit
  def edit
  end

  # POST /orders_sftps
  # POST /orders_sftps.json
  def create
    @orders_sftp = OrdersSftp.new(orders_sftp_params)

    respond_to do |format|
      if @orders_sftp.save
        format.html { redirect_to @orders_sftp, notice: 'Orders sftp was successfully created.' }
        format.json { render action: 'show', status: :created, location: @orders_sftp }
      else
        format.html { render action: 'new' }
        format.json { render json: @orders_sftp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders_sftps/1
  # PATCH/PUT /orders_sftps/1.json
  def update
    respond_to do |format|
      if @orders_sftp.update(orders_sftp_params)
        format.html { redirect_to @orders_sftp, notice: 'Orders sftp was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @orders_sftp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders_sftps/1
  # DELETE /orders_sftps/1.json
  def destroy
    @orders_sftp.destroy
    respond_to do |format|
      format.html { redirect_to orders_sftps_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orders_sftp
      @orders_sftp = OrdersSftp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def orders_sftp_params
      params.require(:orders_sftp).permit(:name)
    end
end
