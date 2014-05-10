class StorehousesController < ApplicationController
  before_action :set_storehouse, only: [:show, :edit, :update, :destroy]

  # GET /storehouses
  # GET /storehouses.json
  def index
    @storehouses = Storehouse.all
  end

  # GET /storehouses/1
  # GET /storehouses/1.json
  def show
  end

  # GET /storehouses/new
  def new
    @storehouse = Storehouse.new
  end

  # GET /storehouses/1/edit
  def edit
  end

  # POST /storehouses
  # POST /storehouses.json
  def create
    @storehouse = Storehouse.new(storehouse_params)

    respond_to do |format|
      if @storehouse.save
        format.html { redirect_to @storehouse, notice: 'Storehouse was successfully created.' }
        format.json { render action: 'show', status: :created, location: @storehouse }
      else
        format.html { render action: 'new' }
        format.json { render json: @storehouse.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /storehouses/1
  # PATCH/PUT /storehouses/1.json
  def update
    respond_to do |format|
      if @storehouse.update(storehouse_params)
        format.html { redirect_to @storehouse, notice: 'Storehouse was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @storehouse.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /storehouses/1
  # DELETE /storehouses/1.json
  def destroy
    @storehouse.destroy
    respond_to do |format|
      format.html { redirect_to storehouses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_storehouse
      @storehouse = Storehouse.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def storehouse_params
      params.require(:storehouse).permit(:capacity, :type)
    end
end
