module Api
  module V1
    class PostsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      before_action :set_post, only: [:destroy]

      def index
        posts = Post.includes(:user, image_attachment: :blob).order(created_at: :desc)
        render json: posts.map { |post| serialize_post(post) }
      end

      def show
        post = Post.find_by(id: params[:id])
        if post
          render json: post.as_json(
            only: [:id, :content, :created_at],
            include: { user: { only: [:id, :username] } }
          )
        else
          render json: { error: "Post not found" }, status: :not_found
        end
      end

      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          render json: { message: "Post created!", post: @post }, status: :created
        else
          render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @post.user == current_user
          @post.destroy
          render json: { message: "Post deleted successfully!" }, status: :ok
        else
          render json: { error: "Not authorized to delete this post." }, status: :forbidden
        end
      end

      private

      def set_post
        @post = Post.find_by(id: params[:id])
        unless @post
          render json: { error: "Post not found" }, status: :not_found
        end
      end

      def serialize_post(post)
        {
          id: post.id,
          content: post.content,
          author: post.user.username,
          image_url: post.image.attached? ? url_for(post.image) : nil,
          created_at: post.created_at
        }
      end

      def post_params
        params.require(:post).permit(:content,:title)
      end
    end
  end
end
