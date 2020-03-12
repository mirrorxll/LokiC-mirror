# frozen_string_literal: true

class CreateJoinTableStoryTypeFrequency < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :story_types, :frequencies, table_name: 'story_types__frequencies' do |t|
      t.index :story_type_id, unique: true
      t.index %i[frequency_id story_type_id]
    end
  end
end
