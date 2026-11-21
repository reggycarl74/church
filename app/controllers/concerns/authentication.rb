module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_login
    helper_method :current_user, :logged_in?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_login, **options
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in? = current_user.present?

  def require_login
    return if logged_in?
    session[:return_to] = request.fullpath if request.get?
    redirect_to login_path
  end

  def require_admin
    redirect_to root_path, alert: "Only administrators can do that." unless current_user&.admin?
  end

  def start_session_for(user)
    reset_session
    session[:user_id] = user.id
  end
end
