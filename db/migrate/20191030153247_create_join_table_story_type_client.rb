# frozen_string_literal: true

class CreateJoinTableStoryTypeClient < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_join_table :story_types, :clients, table_name: 'story_types__clients' do |t|
      t.index %i[story_type_id client_id], unique: true
    end
  end
end
