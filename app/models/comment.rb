class Comment < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :post
  belongs_to :comment, optional: true
  has_many :comments, dependent: :destroy
  validates :body, length: { in: 2..400 }, presence: true

  def comment_json
    new_comment = attributes
    new_comment['author'] = author.username
    new_comment
  end

  def self.author_comments_json(comments_array)
    returned_comments = []
    comments_array.each do |comment|
      new_comment = comment.as_json
      new_comment['post_author'] = comment.post.author.username
      new_comment['post_title'] = comment.post.title
      new_comment['forum'] = comment.post.forum.name
      new_comment['subforum'] = comment.post.subforum if comment.post.subforum.present?
      new_comment['author'] = comment.author.username
      returned_comments.push(new_comment)
    end

    returned_comments
  end
end
