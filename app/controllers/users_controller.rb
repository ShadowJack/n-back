# Managing login action, creation of new user,
# getting existed user, managing user options
class UsersController < ApplicationController
  before_action :set_user, only: [:play, :save_options, :show_options, :show, :update, :destroy]
  skip_before_filter :verify_authenticity_token, only: [:login, :save_options]

  def login
    params.permit :id
    session[:uid] = params[:id][/\d+/]
    logger.debug 'Login: ' + session[:uid]
    resp = { response: true }
    render json: resp, status: :ok
  end

  # GET /play
  def play
    unless create_user
      respond_to do |format|
        format.html { render 'layouts/unauthorized_error' }
        format.json { render json: { error: "Can't find and create user - no uid available" }, status: 401 }
      end
      return
    end
    @options = { nsteps: @user.options.split('')[0].to_i, type: @user.options.split('')[1..-1] }
  end

  # GET /user
  # GET /user.json
  def show
    if create_user
      logger.debug @user.inspect
      render json: @user
    else
      render json: { error: 'User is not logged in!' }, status: :unprocessable_entity
    end
  end

  # POST /users
  # POST /users.json
  def create
    logger.debug user_params
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :not_acceptable
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    unless create_user
      respond_to do |format|
        format.json { render json: { error: 'User is not logged in!' }, status: :unprocessable_entity }
      end
      return
    end
    logger.debug '@user is found in db!'

    respond_to do |format|
      if @user.update(user_params)
        format.json { render json: @user, status: :ok, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /options
  def show_options
    unless create_user # havn't found user and didn't manage to create it
      respond_to do |format|
        format.html { render 'layouts/unauthorized_error' }
        format.json { render json: { error: "Can't find and create user - no uid available" }, status: 401 }
      end
      return
    end
    @options = { nsteps: @user.options.split('')[0].to_i, type: @user.options.split('')[1..-1] }
    logger.debug 'Current user options: ' + @options.to_s
    respond_to do |format|
      format.html
      format.json { render json: @user.options }
    end
  end

  # POST /options
  def save_options
    unless create_user
      respond_to do |format|
        format.html { render 'layouts/unauthorized_error' }
        format.json { render json: { error: "Can't find and create user - no uid available" }, status: 401 }
      end
      return
    end
    new_options = options_params.values[0] + options_params.values[1..-1].sort.reverse.join('') # sort as 'spfc'
    logger.debug 'Updating options: ' + new_options.to_s
    if new_options.length <= 1
      respond_to do |format|
        format.html { redirect_to show_options_path(vk_id: params[:vk_id]), alert: 'Выберите хотя бы один признак!' }
        format.json { render json: { error: 'Unsuccessful options update' }, status: 401 }
      end
      return
    end
    respond_to do |format|
      if @user.update(options: new_options)
        format.html { redirect_to show_options_path(vk_id: params[:vk_id]), notice: 'Настройки были успешно сохранены.' }
        format.json { render json: { options: new_options }, status: :ok }
      else
        format.html { redirect_to show_options_path(vk_id: params[:vk_id]), alert: 'Не удалось сохранить Ваши настройки =(' }
        format.json { render json: { error: 'Unsuccessful options update' }, status: 401 }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    logger.debug 'In set_user, session[:uid]=' + session[:uid].to_s
    logger.debug 'In set_user, params[:vk_id]' + params[:vk_id].to_s
    if !session[:uid].nil?
      logger.debug 'Searching for player with vk_id ' + session[:uid].to_s
      @user = User.find_by_vk_id session[:uid]
    elsif !params[:vk_id].nil?
      logger.debug 'Searching for player with vk_id ' + params[:vk_id].to_s
      @user = User.find_by_vk_id params[:vk_id]
    else
      logger.error 'User is not logged in'
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:score, :options, :vk_id)
  end

  def options_params
    params.permit(:nsteps, :color, :position, :sound, :form)
  end

  def create_user
    if @user.nil?
      # trying to create a new user
      if !session[:uid].nil?
        @user = User.new(score: 0, options: '2sp', vk_id: session[:uid])
        @user.save
      elsif !params[:vk_id].nil?
        @user = User.new(score: 0, options: '2sp', vk_id: params[:vk_id])
        @user.save
      else
        return false
      end
    end
    true
  end
end
