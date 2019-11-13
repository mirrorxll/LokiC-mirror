# frozen_string_literal: true

class CreateJoinTableStoryDataLocation < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :stories, :data_locations, table_name: 'stories__data_locations' do |t|
      t.index %i[story_id data_location_id], unique: true
    end
  end
end
