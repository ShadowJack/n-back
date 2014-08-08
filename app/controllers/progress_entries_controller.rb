class ProgressEntriesController < ApplicationController
  before_action :set_progress_entry, only: [:show, :edit, :update, :destroy]
  before_action :set_user, only: [:index, :create]
  # GET /progress_entries
  # GET /progress_entries.json
  def index
    @progress_entries = @user.progress_entries
    @options = {"s" => "Звук", "p" => "Позиция", "f" => "Форма", "c" => "Цвет"}
    @score = 0
    @score_mapping = []
    @progress_entries_list = []
    counter = 1
    for entry in @progress_entries
      results = entry.result.split(" ").map{|res| res[1..-1]}
      coeff = 1 + entry.nsteps * (results.count - 1)
      all = 0
      right = 0
      results.each do |res|
        all += res.split("-")[0].to_i
        right += res.split("-")[1].to_i
      end
      @score += (right * 100 / all).floor * coeff
      @score_mapping.push [counter.to_s, @score, entry.created_at]
      @progress_entries_list << {entry: entry, counter: counter}
      counter += 1
    end
    logger.debug @score_mapping
    @progress_entries_list = @progress_entries_list.reverse[0..9]
    respond_to do |format|
      format.html
      format.json {render json: [{name: "Счет", data: @score_mapping}]}
    end
  end


  def data
    
  end
  # GET /progress_entries/1
  # GET /progress_entries/1.json
  def show
  end

  # GET /progress_entries/new
  def new
    @progress_entry = ProgressEntry.new
  end

  # GET /progress_entries/1/edit
  def edit
  end

  # POST /progress_entries
  # POST /progress_entries.json
  def create
    @progress_entry = ProgressEntry.new(progress_entry_params.merge(user_id: @user.id))
    logger.debug "New progress entry to be created: " + @progress_entry.inspect
    respond_to do |format|
      if @progress_entry.save
        format.html { redirect_to @progress_entry, notice: 'Progress entry was successfully created.' }
        format.json { render :show, status: :created, location: @progress_entry }
      else
        format.html { render :new }
        format.json { render json: @progress_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /progress_entries/1
  # PATCH/PUT /progress_entries/1.json
  def update
    respond_to do |format|
      if @progress_entry.update(progress_entry_params)
        format.html { redirect_to @progress_entry, notice: 'Progress entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @progress_entry }
      else
        format.html { render :edit }
        format.json { render json: @progress_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /progress_entries/1
  # DELETE /progress_entries/1.json
  def destroy
    @progress_entry.destroy
    respond_to do |format|
      format.html { redirect_to progress_entries_url, notice: 'Progress entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_progress_entry
      @progress_entry = ProgressEntry.find(params[:id])
    end
    
    def set_user
      if session[:uid].nil?
        respond_to do |format|
          format.html {render template: 'layouts/unauthorized_error'}
          format.json {render json: {error: true}}
        end
        return
      end
      @user = User.find_by_vk_id(session[:uid])
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def progress_entry_params
      params.permit(:result, :nsteps, :user_id)
    end
end
