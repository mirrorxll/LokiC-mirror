# frozen_string_literal: true

class AddPublicationToStoryTypeClientPublicationTags < ActiveRecord::Migration[6.0]
  def change
    add_reference :story_type_client_publication_tags, :publication,
                  foreign_key: true,  after: :client_id
  end
end
