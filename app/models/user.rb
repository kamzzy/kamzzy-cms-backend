# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :posts, inverse_of: 'author', dependent: :destroy
  has_many :comments, dependent: :destroy
  validates :username, length: { in: 4..32 }, presence: true,
                       uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :admin_level, numericality: { only_integer: true,
                                          less_than_or_equal_to: 3 }
  before_save { username.downcase! }
  before_save { email.downcase! }

  def password_token_expired?
    offset = (Time.zone.now - password_reset_date).round
    offset / 1.hours >= 1 # Token expires after 1 hour
  end
end
