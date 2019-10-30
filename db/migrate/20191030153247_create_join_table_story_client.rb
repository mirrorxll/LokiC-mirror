# frozen_string_literal: true

class CreateJoinTableStoryClient < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :stories, :clients do |t|
      t.index %i[story_id client_id], unique: true
    end
  end
end
