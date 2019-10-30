# frozen_string_literal: true

class CreateJoinTableStoryStorySection < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :stories, :story_sections do |t|
      t.index %i[story_id story_section_id], unique: true
    end
  end
end
