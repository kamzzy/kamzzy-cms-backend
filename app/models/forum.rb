# frozen_string_literal: true

class Forum < ApplicationRecord
  has_many :subforums, dependent: :destroy
  has_many :posts, dependent: :destroy
  validates :name, length: { in: 3..32 }, presence: true,
                   uniqueness: { case_sensitive: false }
  before_save { name.downcase! }

  # Grabs all posts without a subforum, while also limiting the amount posts retrieved
  def subforum_posts(per_page = 10, page = 1)
    offset = (page * per_page) - per_page
    retrieved_posts = posts.where(subforum_id: nil)
                           .offset(offset).limit(per_page)

    Forum.truncate_posts(retrieved_posts)
  end

  # Truncates posts title and body attribute returning a new array
  def self.truncate_posts(posts)
    returned_posts = []
    posts.each do |post|
      new_post = post.as_json(only: %i[id user_id is_pinned created_at])
      new_post['title'] = post.title.slice(0..30)
      new_post['body'] = post.body.slice(0..32)
      new_post['author'] = post.author.username
      new_post['subforum'] = post.subforum.name if post.subforum.present?
      new_post['forum'] = post.forum.name
      returned_posts.push(new_post)
    end

    returned_posts
  end

  def self.forum_all_json
    returned_json = []
    Forum.all.each do |forum|
      new_forum = forum.as_json
      new_forum['subforums'] = forum.subforums.as_json(only: %i[id name])

      returned_json.push(new_forum)
    end

    returned_json
  end
end
