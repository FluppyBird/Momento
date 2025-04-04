class ProfilesController < ApplicationController
  before_action :set_user_and_profile, only: [:show, :edit, :update]
  before_action :authenticate_user!

  def show
    @posts = @user.posts.order(created_at: :desc)
    @followers_count = @user.followers.count
    @following_count = @user.following.count
  end

  def edit
    redirect_to root_path, alert: "You can not edit other's profile!" unless @user == current_user
  end

  def update
    if @profile.update(profile_params)
      respond_to do |format|
        format.html { redirect_to profile_path(@user), notice: "Profile was successfully updated!" }
        format.turbo_stream do
          flash.now[:notice] = "Profile was successfully updated!"
          render turbo_stream: turbo_stream.replace("profile_info", partial: "profiles/profile_info", locals: { user: @user })
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end


  private

  def set_user_and_profile
    @user = User.find(params[:id])
    # @profile = @user.profile || @user.create_profile
    @profile = @user.profile
  end

  def profile_params
    params.require(:profile).permit(:bio, :avatar)
  end
end
