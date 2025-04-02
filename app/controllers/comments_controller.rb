class CommentsController < ApplicationController
  before_action :require_login, :find_post

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: "comments added successfully！"
    else
      redirect_to post_path(@post), alert: "comments added failed!"
    end
  end

  private

  def find_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
