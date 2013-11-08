class TrialsController < ApplicationController
  before_action :set_trial, only: [:show, :edit, :update, :destroy]
  
  # GET /trials
  # GET /trials.json
  def index
   

      @trials = Trial.search_for(params[:q]).age(params[:age]).control?(params[:volunteer_type]).gender(params[:gender]).order('title ASC').paginate(:page => params[:page], :per_page => 10)
#      @sites = Site.near(params[:pc],params[:travel_distance]).where(trials_ids: @trial_ids).paginate(:page => params[:page], :per_page => 10)

      # @TODO create session variable for each paramter.
      session[:age] = params[:age]
      session[:volunteer_type] = params[:volunteer_type]
      session[:gender] = params[:gender]
      session[:pc] = params[:pc]
      session[:travel_distance] = params[:travel_distance]

    # rescue # Need to name raised error
    #   flash.alert = "Your zip code is not valid!"
    #   render "index"
   
  end


  # GET /trials/1
  # GET /trials/1.json
  def show
    @trial = Trial.find params[:id]
    # @TODO? I'm running distance_from in both the controller and view. Should this just be done in the model??
    @sites = @trial.sites.sort_by{|site| site.distance_from([40.7522926,-73.9900131])}



  end

  # GET /trials/new
  def new
    @trial = Trial.new

    # @TODO? Should i used nested parameters so that the trial and site location are run through the trials controller? or should i add a sites controller?
  end

  # GET /trials/1/edit
  def edit
  end

  # POST /trials
  # POST /trials.json
  def create
    @trial = Trial.new(trial_params)

    respond_to do |format|
      if @trial.save
        format.html { redirect_to @trial, notice: 'Trial was successfully created.' }
        format.json { render action: 'show', status: :created, location: @trial }
      else
        format.html { render action: 'new' }
        format.json { render json: @trial.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trials/1
  # PATCH/PUT /trials/1.json
  def update
    respond_to do |format|
      if @trial.update(trial_params)
        format.html { redirect_to @trial, notice: 'Trial was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @trial.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trials/1
  # DELETE /trials/1.json
  def destroy
    @trial.destroy
    respond_to do |format|
      format.html { redirect_to trials_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trial
      @trial = Trial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trial_params
      params.require(:trial).permit(:title, :description, :sponsor, :country, :focus)
    end
end
