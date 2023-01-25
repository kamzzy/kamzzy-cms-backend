# frozen_string_literal: true

class SubforumsController < ApplicationController
  before_action :authorized_admin?, only: %i[create update destroy]
  before_action :set_forum, only: %i[create]
  before_action :set_subforum, only: %i[update destroy]

  def create
    @forum.subforums.create!(subforum_params)
    json_response(forums: Forum.forum_all_json)
  end

  def update
    if @subforum.update(subforum_params)
      json_response(forums: Forum.forum_all_json)
    else
      json_response({ errors: @forum.errors.full_messages }, 401)
    end
  end

  def destroy
    @subforum.destroy
    json_response(forums: Forum.forum_all_json)
  end

  private

  def set_forum
    @forum = Forum.find(params[:subforum][:forum_id])
  end

  def set_subforum
    @subforum = Subforum.find(params[:id])
  end

  def subforum_params
    params.require(:subforum).permit(:name)
  end
end
