class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  # helper_method :current_user, :logged_in?
  # allow_browser versions: :modern

  private

  def configure_permitted_parameters
    # 注册和编辑用户资料时允许 username
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  # def current_user
  #   @current_user ||= User.find_by(id: session[:user_id])
  # end
  #
  # def logged_in?
  #   !!current_user
  # end
  #
  # def require_login
  #   unless logged_in?
  #     redirect_to new_user_session_path, notice: "please login first!"
  #   end
  # end
end
