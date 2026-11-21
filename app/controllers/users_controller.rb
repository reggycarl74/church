class UsersController < ApplicationController
  before_action :require_admin, except: %i[password update_password]

  def index
    @users = User.order(:name)
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:name, :email_address, :password, :admin))
    if @user.save
      redirect_to users_path, notice: "User #{@user.name} added."
    else
      @users = User.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    if user == current_user
      redirect_to users_path, alert: "You cannot delete yourself."
    else
      user.destroy!
      redirect_to users_path, notice: "User removed."
    end
  end

  def password; end

  def update_password
    if !current_user.authenticate(params[:current_password].to_s)
      flash.now[:alert] = "Current password is wrong."
      render :password, status: :unprocessable_entity
    elsif current_user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      redirect_to root_path, notice: "Password changed."
    else
      flash.now[:alert] = current_user.errors.full_messages.to_sentence
      render :password, status: :unprocessable_entity
    end
  end
end
