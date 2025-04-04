class FollowsController < ApplicationController
  def create
    @user = User.find(params[:id])
    current_user.follow(@user)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to profile_path(@user), notice: "Follow successfully11!" }
    end
  end

  def destroy
    @user = User.find(params[:id])
    current_user.unfollow(@user)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to profile_path(@user), notice: "Unfollow successfully22!" }
    end
  end
end
