# frozen_string_literal: true

class CreateJoinTableStoryTypeTag < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_join_table :story_types, :tags, table_name: 'story_types__tags' do |t|
      t.index %i[story_type_id tag_id], unique: true
    end
  end
end
