class UsersController < ApplicationController
  before_action :current_user, only: [:show, :follow, :unfollow]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Register successfully!"
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    # @user = current_user
    @posts = @user.posts.includes(:likes, :comments)
  end

  def follow
    @user = User.find(params[:id])
    if current_user.following.include?(@user)
      flash[:notice] = "You have already followed!"
    else
      current_user.following << @user
      flash[:notice] = "Followed Successfully!"
    end
    redirect_back(fallback_location: root_path)
  end

  def unfollow
    @user = User.find(params[:id])
    if current_user.following.include?(@user)
      current_user.following.delete(@user)
      flash[:notice] = "Unfollowed Succesfully!"
    end
    # redirect_to user_path(@user)
    redirect_back(fallback_location: root_path)
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
