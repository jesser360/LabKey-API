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
  end

  def fetch_animal participantId
    auth = {:username => 'apikey', :password => ENV['LABKEY_API_KEY']}
    @response = HTTParty.get("http://pczt-win-lbk-a1.primate.ucdavis.edu:8080/labkey/query/CNPRC/selectRows.api?schemaName=study&query.queryName=housing&query.maxRows=40&query.participantid~eq=#{participantId}",:basic_auth => auth)

  end


  # GET /animals/new
  def new
    @animal = Animal.new

    auth = {:username => 'apikey', :password => ENV['LABKEY_API_KEY']}
    @rooms = []
    @response = HTTParty.get("http://pczt-win-lbk-a1.primate.ucdavis.edu:8080/labkey/query/CNPRC/selectRows.api?schemaName=ehr_lookups&query.queryName=rooms&query",:basic_auth => auth)
    @response['rows'].each do |row|
       @rooms.push(row['room'])
    end

  end

  # GET /animals/1/edit
  def edit
    auth = {:username => 'apikey', :password => ENV['LABKEY_API_KEY']}
    @rooms = []
    @response = HTTParty.get("http://pczt-win-lbk-a1.primate.ucdavis.edu:8080/labkey/query/CNPRC/selectRows.api?schemaName=ehr_lookups&query.queryName=rooms&query",:basic_auth => auth)
    @response['rows'].each do |row|
       @rooms.push(row['room'])
    end
  end

  # POST /animals
  # POST /animals.json
  def create
    @search = Animal.new(animal_params)
    auth = {:username => 'apikey', :password => ENV['LABKEY_API_KEY']}
    @participantId = animal_params[:participantId]
    @previous = HTTParty.get("http://pczt-win-lbk-a1.primate.ucdavis.edu:8080/labkey/query/CNPRC/selectRows.api?schemaName=study&query.queryName=housing&query.maxRows=1&query.participantid~eq=#{@participantId}",:basic_auth => auth)
    @result = HTTParty.post("http://pczt-win-lbk-a1.primate.ucdavis.edu:8080/labkey/query/CNPRC/insertRows.api",:basic_auth => auth,
    :body => {"schemaName": "study",
              "queryName": "housing",
              "command": "update",
              "rowsAffected": 1,
              "rows": [
                {"participantId": animal_params[:participantId],
                 "modifiedBy": 1004,
                 # "date": @previous['rows'][0]['enddate'],
                 "date": animal_params[:date],
                 "room": animal_params[:room],
                 "cage": animal_params[:cage],
                 "reloc_seq": @previous['rows'][0]['reloc_seq'].to_i + 1,
                 "Key":SecureRandom.hex.to_s
                 }
              ]
            }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )
    puts @result
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
    auth = {:username => 'apikey', :password => ENV['LABKEY_API_KEY']}
    @result = HTTParty.post("http://pczt-win-lbk-a1.primate.ucdavis.edu:8080/labkey/query/CNPRC/insertRows.api",:basic_auth => auth,
    :body => {"schemaName": "study",
              "queryName": "housing",
              "command": "update",
              "rowsAffected": 1,
              "rows": [
                {"participantId": animal_params[:participantId],
                 "modifiedBy": 1004,
                 "date": "2014-05-07 00:00:00.000",
                 "enddate": "2014-05-08 00:00:00.000",
                 "room": params['room'],
                 "reloc_seq": animal_params[:reloc_seq],
                 "Key":SecureRandom.hex.to_s
                 }
              ]
            }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )

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
      params.require(:animal).permit(:participantId, :date, :room, :reloc_seq, :objectId,:enddate,:cage)
    end
end
