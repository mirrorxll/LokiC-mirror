# frozen_string_literal: true

class CreateStoryTypesClientsTags < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :story_type_client_tags do |t|
      t.belongs_to :story_type
      t.belongs_to :client
      t.belongs_to :tag

      t.index %i[story_type_id client_id tag_id], unique: true, name: 'story_types_clients_tags_unique_index'
    end
  end
end
