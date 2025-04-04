class PostsController < ApplicationController
  def index
    @posts = Post.all.order(created_at: :desc)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      if @post.image.attached?
        @post.image.analyze unless @post.image.analyzed?
        @post.image.analyze unless @post.image.metadata.present?

        wait_time = 0
        until @post.image.metadata[:width].present? || wait_time > 3
          sleep 0.1
          wait_time += 0.1
        end
      end

      redirect_to root_path, notice: "Post created successfully!"
    else
      Rails.logger.error @post.errors.full_messages.inspect
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @post = Post.find(params[:id])
    @user = @post.user
    @comments = @post.comments.includes(:user)
    @new_comment = Comment.new
  end

  def destroy
    @post = Post.find(params[:id])
    if @post.user == current_user
      @post.destroy
      redirect_to root_path, notice: "Post deleted successfully."
    else
      redirect_to root_path, alert: "You are not authorized to delete this post."
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :image)
  end
end