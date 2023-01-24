class ForumsController < ApplicationController
  before_action :authorized_admin?, only: %i[create update destroy]
  before_action :set_forum, only: %i[update destroy]
  before_action :set_page_params, only: %i[index show_by_forum show_by_subforum]

  # Shows all Forum records and appends their posts and subforums by
  # adding new keys after converting to a hash
  def index
    all_forums = []
    Forum.all.each do |forum|
      new_forum = forum.attributes
      new_forum['posts'] = forum.subforum_posts(@per_page, @page)
      new_forum['subforums'] = return_subforums(forum, @per_page, @page)
      all_forums.push new_forum
    end

    json_response(results: { forums: all_forums, pinned_posts: Post.pins_json,
                             per_page: @per_page, page: @page })
  end

  # Shows all Forum records and their related subforums
  def index_all
    json_response(forums: Forum.forum_all_json)
  end

  # Similar process to the index method but only shows one Forum record
  # along with its Subforums and their posts
  def show_by_forum
    forum = Forum.find_by(name: params[:forum])
    selected_forum = forum.attributes
    selected_forum['posts'] = forum.subforum_posts(@per_page, @page)
    selected_forum['subforums'] = return_subforums(forum, @per_page, @page)

    json_response(results: { forum: selected_forum,
                             per_page: @per_page, page: @page })
  end

  # Shows not only the Forum record but the posts for a specific Subforum
  def show_by_subforum
    forum = Forum.find_by(name: params[:forum])
    selected_forum = forum.attributes

    subforum = Subforum.find_by(name: params[:subforum])
    selected_forum['posts'] = []
    new_subforum = { id: subforum.id,
                     subforum: subforum.name,
                     posts: subforum.subforum_posts(@per_page, @page) }
    selected_forum['subforums'] = [new_subforum]

    json_response(results: { forum: selected_forum,
                             per_page: @per_page, page: @page })
  end

  # Creates a Forum record and populates its Subforums through association
  # building. The params[:forum][:subforums] is an array of names for the
  # Subforums to be created.
  def create
    forum = Forum.create!(forum_params)
    all_subforums = params[:forum][:subforums]
    new_subforums = []
    all_subforums.each do |sub|
      new_hash = { name: sub }
      new_subforums.push(new_hash)
    end
    forum.subforums.create!(new_subforums)
    json_response(forums: Forum.forum_all_json)
  end

  def update
    if @forum.update(forum_params)
      json_response(forums: Forum.forum_all_json)
    else
      json_response({ errors: @forum.errors.full_messages }, 401)
    end
  end

  def destroy
    @forum.destroy
    json_response(forums: Forum.forum_all_json)
  end

  private

  def set_forum
    @forum = Forum.find(params[:id])
  end

  def set_page_params
    @per_page = params[:per_page].present? ? params[:per_page].to_i : 5
    @page = params[:page].present? ? params[:page].to_i : 1
  end

  def return_subforums(forum, per_page, page)
    all_subforums = []
    forum.subforums.each do |subforum|
      new_subforum = { id: subforum.id,
                       subforum: subforum.name,
                       posts: subforum.subforum_posts(per_page, page) }
      all_subforums.push(new_subforum)
    end

    all_subforums
  end

  def forum_params
    params.require(:forum)
          .permit(:name, :admin_only, :admin_only_view)
  end
end
