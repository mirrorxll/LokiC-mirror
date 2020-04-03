# frozen_string_literal: true

class CreateJoinTableStoryTypesClients < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_join_table :story_types, :clients do |t|
      t.index %i[story_type_id client_id], unique: true
    end
  end
end
