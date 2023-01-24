# frozen_string_literal: true

class CreateSubforums < ActiveRecord::Migration[7.0]
  def change
    create_table :subforums do |t|
      t.string :name
      t.belongs_to :forum, null: false, foreign_key: true

      t.timestamps
    end
  end
end
