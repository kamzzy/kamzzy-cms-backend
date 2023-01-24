# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.belongs_to :forum, null: false, foreign_key: true
      t.belongs_to :subforum, null: true
      t.boolean :is_pinned, default: false
      t.boolean :is_locked, default: false
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
