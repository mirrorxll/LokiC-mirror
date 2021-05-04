# frozen_string_literal: true

class ChangeIndexInStoryTypeClientPublicationTags < ActiveRecord::Migration[6.0]
  def change
    remove_index :story_type_client_publication_tags,
                 name: :story_types_clients_tags_unique_index
    add_index :story_type_client_publication_tags,
              [:story_type_id, :client_id, :publication_id],
              unique: true, name: 'story_types_clients_publications_unique_index'
  end
end
