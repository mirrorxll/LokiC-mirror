# frozen_string_literal: true

class CreateJoinTableStoryTypeStatus < ActiveRecord::Migration[5.2]
  def change
    create_join_table :story_types, :statuses do |t|
      t.index %i[story_type_id status_id], unique: true
    end
  end
end
