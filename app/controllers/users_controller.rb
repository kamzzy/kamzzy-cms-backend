class UsersController < ApplicationController
  before_action :authorized_user?, only: %i[update_image]
  before_action :authorized_admin?, only: %i[suspend_communication set_admin_level]
  before_action :set_user, only: %i[show update_image set_admin_level suspend_communication]

  def index
    all_users = User.all.order(created_at: :desc)
    users_array = []
    all_users.each do |user|
      new_user = user.as_json(only: %i[id username is_activated admin_level])
      new_user['can_post'] = DateTime.now > user.can_post_date
      new_user['can_comment'] = DateTime.now > user.can_comment_date
      new_user['profile_image'] = nil
      unless user.profile_image_attachment.nil?
        new_user['profile_image'] = url_for(user.profile_image)
      end
      users_array.push(new_user)
    end

    json_response(users: users_array)
  end

  def show
    json_response(user: user_with_image(@user))
  end

  def update_image
    if @current_user.update_attribute(:profile_image, params[:user][:profile_image])
      json_response(user: user_with_image(@current_user))
    else
      json_response({ errors: @current_user.errors.full_messages }, 401 )
    end
  end

  # Change a user's administrative level
  def set_admin_level
    error_desc = 'Your admin level is too low'
    error_desc2 = "Can't change the administrative level of the site owner"

    return json_response({ errors: error_desc }, 401)  if @current_user.admin_level < 2

    return json_response({ errors: error_desc2 }, 401) if @user.admin_level == 3

    @user.update_attribute(:admin_level, params[:user][:admin_level])
    json_response(user: user_with_image(@user))
  end

  def suspend_communication
    error_desc = 'You do not have the necessary privileges'
    error_desc2 = 'Ban dates cannot be blank'
    error_desc3 = 'Ban dates must be in array format'

    return json_response({ errors: error_desc }, 401) if @current_user.admin_level < 1

    post_ban = params[:user][:can_post_date]
    comment_ban = params[:user][:can_comment_date]

    return json_response({ errors: error_desc2 }, 401) if post_ban.nil? || comment_ban.nil?
    return json_response({ errors: error_desc3 }, 401) unless post_ban.is_a?(Array) && comment_ban.is_a?(Array)

    suspend_comms(@user, post_ban, :can_post_date)
    suspend_comms(@user, comment_ban, :can_comment_date)

    json_response(user: user_with_image(@user))
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def suspend_comms(user, comms, attr)
    comms_i = comms.map(&:to_i)
    d = DateTime.now
    ban_date = DateTime.new(comms_i[0], comms_i[1], comms_i[2], comms_i[3], comms_i[4], 0, d.offset);
    user.update_attribute(attr, ban_date)
  end

  # Returns a hash object of a user with their profile_image included
  def user_with_image(user)
    user_with_attachment = user.as_json(only: %i[id username is_activated
                                                 admin_level can_post_date
                                                 can_comment_date])
    user_with_attachment['profile_image'] = nil
    user_with_attachment['posts'] = Post.author_posts_json(user.posts)
    user_with_attachment['comments'] = Comment.author_comments_json(user.comments.last(3))
    user_with_attachment['can_post'] = DateTime.now > user.can_post_date
    user_with_attachment['can_comment'] = DateTime.now > user.can_comment_date
    user_with_attachment['server_date'] = DateTime.now

    unless user.profile_image_attachment.nil?
      user_with_attachment['profile_image'] = url_for(user.profile_image)
    end

    user_with_attachment
  end
end
