# frozen_string_literal: true

class CreateJoinTableStoryLevel < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :stories, :levels, table_name: 'stories__levels' do |t|
      t.index %i[story_id level_id], unique: true
      t.index %i[level_id story_id], unique: true
    end
  end
end
