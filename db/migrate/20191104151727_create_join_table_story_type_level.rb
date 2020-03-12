# frozen_string_literal: true

class CreateJoinTableStoryTypeLevel < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :story_types, :levels, table_name: 'story_types__levels' do |t|
      t.index :story_type_id, unique: true
      t.index %i[level_id story_type_id]
    end
  end
end
