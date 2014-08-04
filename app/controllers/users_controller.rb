class UsersController < ApplicationController
  before_action :set_user, only: [:save_options, :show_options, :show, :update, :destroy]

  # GET /users/1
  # GET /users/1.json
  def show
    if @user.nil? 
      # пытаемся создать пользователя
      unless session[:uid].nil?
        @user = User.new(score: 0, options: '2sp', vk_id: session[:uid])
        @user.save
      else
        respond_to do |format|
          format.json {render json: {error: "Can't find and create user - no uid available"}, status: 401}
        end
        return
      end
    end
    logger.debug @user.inspect
    render json: @user
  end

  def login
    params[:id] = params[:id][/\d+/]
    session[:uid] = params[:id]
    logger.debug "Login: " + session[:uid]
    resp = {response: true}
    render json: resp, status: :ok
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
    if @user.nil?
      respond_to do |format|
        format.json {render json: {error: "User is not logged in!"}, status: :unprocessable_entity}
      end
      return
    end
    logger.debug "@user is found in db!"
    
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
    if @user.nil? 
      # пытаемся создать пользователя
      unless session[:uid].nil?
        @user = User.new(score: 0, options: '2sp', vk_id: session[:uid])
        @user.save
      else
        respond_to do |format|
          format.html {render "layouts/unauthorized_error"}
          format.json {render json: {error: "Can't find and create user - no uid available"}, status: 401}
        end
        return
      end
    end
    @options = {nsteps: @user.options.split("")[0].to_i, type: @user.options.split("")[1..-1]}
    logger.debug "Current user options: " + @options.to_s
    respond_to do |format|
      format.html
      format.json {render json: @user.options}
    end
  end
  
  # POST /options
  def save_options
    if @user.nil?
      respond_to do |format|
        format.html {render "layouts/unauthorized_error"}
        format.json {render json: {error: "Can't find and create user - no uid available"}, status: 401}
      end
      return
    end
    new_options = options_params.values.join("")
    logger.debug "Updating options: " + new_options.to_s
    respond_to do |format|
      if @user.update(options: new_options)
        format.html { redirect_to "/options", notice: 'Настройки были успешно сохранены.' }
        format.json {render json: {options: new_options}, status: :ok}
      else
        format.html {redirect_to "/options", alert: 'Не удалось сохранить Ваши настройки =('}
        format.json {render json: {error: "Unsuccessful options update"}, status: 401}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      unless session[:uid].nil?
        @user = User.find_by vk_id: session[:uid]
      else
        logger.error "User is not logged in"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:score, :options, :vk_id)
    end
    
    def options_params
      params.permit(:nsteps, :color, :position, :sound, :form)
    end
end
