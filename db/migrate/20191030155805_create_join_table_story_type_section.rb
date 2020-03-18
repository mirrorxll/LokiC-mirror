# frozen_string_literal: true

class CreateJoinTableStoryTypeSection < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_join_table :story_types, :sections, table_name: 'story_types__sections' do |t|
      t.index %i[story_type_id section_id], unique: true
    end
  end
end
