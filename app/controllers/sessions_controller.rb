class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to login_path, alert: "Too many attempts. Try again later." }

  def new; end

  def create
    user = User.find_by(email_address: params[:email_address].to_s.strip.downcase)
    if user&.authenticate(params[:password].to_s)
      start_session_for(user)
      redirect_to(session.delete(:return_to) || root_path)
    else
      flash.now[:alert] = "Wrong email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Logged out."
  end
end
