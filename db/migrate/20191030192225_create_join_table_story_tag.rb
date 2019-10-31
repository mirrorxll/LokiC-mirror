# frozen_string_literal: true

class CreateJoinTableStoryTag < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :stories, :tags, table_name: 'stories__tags' do |t|
      t.index %i[story_id tag_id], unique: true
    end
  end
end
