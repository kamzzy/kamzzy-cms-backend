# frozen_string_literal: true

class Subforum < ApplicationRecord
  belongs_to :forum
  has_many :posts, dependent: :destroy
  validates :name, length: { in: 3..32 }, presence: true,
                   uniqueness: { case_sensitive: false }
  before_save { name.downcase! }

  # Grabs all posts by subforum, while also limiting the amount of posts retrieved
  def subforum_posts(per_page = 10, page = 1)
    offset = (page * per_page) - per_page
    retrieved_posts = posts.offset(offset).limit(per_page)

    Forum.truncate_posts(retrieved_posts)
  end
end
