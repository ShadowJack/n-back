# Show last user's records
# Create and add new entries
class ProgressEntriesController < ApplicationController
  before_action :set_progress_entry, only: [:show, :edit, :update, :destroy]
  before_action :set_user, only: [:index, :create]
  # GET /progress_entries
  # GET /progress_entries.json
  def index
    @user = User.find_by_vk_id(169568288)
    @progress_entries = @user.progress_entries
    logger.info @progress_entries.inspect
    @options = { 's' => 'Звук', 'p' => 'Позиция', 'f' => 'Форма', 'c' => 'Цвет' }
    @score = 0
    @score_mapping = []
    @progress_entries_list = []
    counter = 1
    @progress_entries.each do |entry|
      results = entry.result.split(' ')
      coeff = 1 + entry.nsteps * (results.count - 1)
      all = 0
      right = 0
      wrong = 0
      description = "#{entry.nsteps}-назад"
      results.each do |res|
        results_array = res[1..-1].split('-').map{|x| x.to_i}
        all += results_array[0]
        right += results_array[1]
        description << " #{@options[res[0]]}: #{right} из #{all}"
        if results_array.length > 2
          wrong += res.split('-')[2].to_i 
          description << "(#{wrong} неверно)"
        end
        description << ","
      end
      description = description[0...-1] # remove last ','
      logger.debug(description)
      if right > wrong
        @score += ((right - wrong) * 100 / all).floor * coeff
      end
      @score_mapping.push [counter.to_s, @score, entry.created_at]
      @progress_entries_list << { entry: entry, counter: counter, description: description }
      counter += 1
      end
    logger.debug 'Score mapping: ' + @score_mapping.inspect
    @progress_entries_list = @progress_entries_list.reverse
    respond_to do |format|
      format.html
      format.json { render json: [{ name: 'Счет', data: @score_mapping }] }
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
    logger.debug 'New progress entry to be created: ' + @progress_entry.inspect
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
      # trying to get uid from parameters
      if params[:vk_id].nil?
        respond_to do |format|
          format.html { render template: 'layouts/unauthorized_error' }
          format.json { render json: { error: true } }
        end
        return
      else
        session[:uid] = params[:vk_id]
        logger.debug 'Session[:uid] ' + session[:uid]
      end
    end
    @user = User.find_by_vk_id(session[:uid])
    logger.debug 'Got the user in UserEntries#index: ' + @user.inspect
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def progress_entry_params
    params.permit(:result, :nsteps, :user_id)
  end
end
