# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.string :email
      t.boolean :is_activated
      t.string :activation_key
      t.string :token
      t.datetime :token_date
      t.string :password_reset_token
      t.datetime :password_reset_date
      t.integer :admin_level
      t.datetime :can_post_date
      t.datetime :can_comment_date

      t.timestamps
    end
  end
end
