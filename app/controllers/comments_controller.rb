# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authorized_user?, except: %i[show]
  before_action :set_post, only: %i[show create update destroy]
  before_action :set_comment, only: %i[show update destroy]

  def show
    json_response(comment: @comment)
  end

  def create
    # user = User.find(params[:comment][:user_id])
    return if suspended(@current_user.can_comment_date)

    comment = @post.comments.build(comment_params)
    if comment.save
      json_response({ comment:,
                      comments: Post.author_comments_json(@post.comments) })
    else
      json_response({ errors: comment.errors.full_messages }, 401)
    end
  end

  def update
    # Only allow the owner of the comment or an administrator to update the comment
    unless @comment.author == @current_user || @current_user.admin_level >= 1
      return json_response({ errors: 'Account not Authorized' }, 401)
    end

    if @comment.update(comment_params)
      json_response({ comment: @comment,
                      comments: Post.author_comments_json(@post.comments) })
    else
      json_response({ errors: @comment.errors.full_messages }, 401)
    end
  end

  def destroy
    # Only allow the owner of the comment or an administrator to destroy the comment
    unless @comment.author == @current_user || @current_user.admin_level >= 1
      return json_response({ errors: 'Account not Authorized' }, 401)
    end

    @comment.destroy
    json_response({ message: 'Comment deleted',
                    comments: Post.author_comments_json(@post.comments) })
  end

  private

  def set_post
    @post = Post.find(params[:comment][:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :comment_id, :user_id)
  end

  def suspended(date)
    if date > DateTime.now
      json_response(errors: ['Your commenting communications
                              are still suspended'])
      return true
    end

    false
  end
end
