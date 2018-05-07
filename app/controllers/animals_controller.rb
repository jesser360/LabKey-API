class AnimalsController < ApplicationController
  before_action :set_animal, only: [:show, :edit, :update, :destroy]
  require 'httparty'
  include HTTParty
  basic_auth 'username', 'password'
  # GET /animals
  # GET /animals.json
  def index
    @animal = Animal.new
    @animals = Animal.all
  end

  # GET /animals/1
  # GET /animals/1.json
  def show
    @animal = Animal.find_by_id(params[:id])
    @participantId = @animal.participantId
    @history_hash = fetch_animal(@participantId)
    # assign_values(weather_hash)
  end

  def fetch_animal participantId
    auth = {:username => ENV['LABKEY_USERNAME'], :password => ENV['LABKEY_PASSWORD']}
    @response = HTTParty.get("http://pczt-win-lbk-a1.primate.ucdavis.edu:8080/labkey/query/CNPRC/selectRows.api?schemaName=study&query.queryName=housing&query.maxRows=10&query.participantid~eq=#{participantId}",:basic_auth => auth)

  end


  # GET /animals/new
  def new
    @animal = Animal.new
  end

  # GET /animals/1/edit
  def edit
  end

  # POST /animals
  # POST /animals.json
  def create
    @search = Animal.new(animal_params)
    if @search.save
      redirect_to animal_path(@search)
    else
      flash[:error] = @search.errors.full_messages.join(", ")
      redirect_to :back
    end
  end

  # PATCH/PUT /animals/1
  # PATCH/PUT /animals/1.json
  def update
    respond_to do |format|
      if @animal.update(animal_params)
        format.html { redirect_to @animal, notice: 'Animal was successfully updated.' }
        format.json { render :show, status: :ok, location: @animal }
      else
        format.html { render :edit }
        format.json { render json: @animal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /animals/1
  # DELETE /animals/1.json
  def destroy
    @animal.destroy
    respond_to do |format|
      format.html { redirect_to animals_url, notice: 'Animal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_animal
      @animal = Animal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def animal_params
      params.require(:animal).permit(:participantId, :date, :room, :reloc_seq, :objectId)
    end
end
