# frozen_string_literal: true

class CreateJoinTableStorySection < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :stories, :sections, table_name: 'stories__sections' do |t|
      t.index %i[story_id section_id], unique: true
      t.index %i[section_id story_id], unique: true
    end
  end
end
