class LikesController < ApplicationController
  before_action :require_login, :find_post

  def create
    @like = @post.likes.build(user: current_user)

    if @like.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to post_path(@post), notice: "👍 Liked!" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("like_button_#{@post.id}", partial: "posts/like_button", locals: { post: @post }) }
        format.html { redirect_to post_path(@post), alert: "Something went wrong" }
      end
    end
  end

  def destroy
    @like = @post.likes.find(params[:id])
    @like.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to post_path(@post), notice: "Liked removed!" }
    end
  end

  private

  def find_post
    @post = Post.find(params[:post_id])
  end
end
