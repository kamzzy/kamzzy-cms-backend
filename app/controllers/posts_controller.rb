class PostsController < ApplicationController
  before_action :authorized_user?, except: %i[show lock_post pin_post]
  before_action :authorized_admin?, only: %i[lock_post pin_post]
  before_action :set_post, only: %i[show update destroy lock_post pin_post]

  def show
    json_response({ post: @post.post_json,
                    comments: Post.author_comments_json(@post.comments) })
  end

  def create
    return if suspended(@current_user.can_post_date)

    post = @current_user.posts.build(post_params)
    if post.save
      json_response(post: post.post_json)
    else
      json_response({ errors: post.errors.full_messages }, 401)
    end
  end

  def update
    # Only allow the owner of the post or an administrator to update the post
    unless @post.author == @current_user || @current_user.admin_level >= 1
      return json_response({ errors: 'Account not Authorized' }, 401)
    end

    if @post.update(post_params)
      json_response(post: @post.post_json)
    else
      json_response({ errors: @post.errors.full_messages }, 401)
    end
  end

  def destroy
    # Only allow the owner of the post or an administrator to destroy the post
    unless @post.author == @current_user || @current_user.admin_level >= 1
      return json_response({ errors: 'Account not Authorized' }, 401)
    end

    @post.destroy
    json_response('Post destroyed')
  end

  def lock_post
    if @post.update(is_locked: !@post.is_locked)
      json_response(post: @post.post_json)
    else
      json_response({ errors: @post.errors.full_messages }, 401)
    end
  end

  def pin_post
    if @post.update(is_pinned: !@post.is_pinned)
      json_response(post: @post.post_json)
    else
      json_response({ errors: @post.errors.full_messages }, 401)
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :subforum_id, :is_pinned,
                                 :is_locked, :forum_id)
  end

  def suspended(date)
    if date > DateTime.now
      json_response(errors: ['Your posting communications are still suspended'])
      return true
    end

    false
  end
end
