# frozen_string_literal: true

class CreateJoinTableStoryFrequency < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :stories, :frequencies, table_name: 'stories__frequencies' do |t|
      t.index :story_id, unique: true
      t.index %i[frequency_id story_id]
    end
  end
end
