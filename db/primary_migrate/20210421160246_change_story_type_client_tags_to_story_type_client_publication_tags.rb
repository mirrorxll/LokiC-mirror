# frozen_string_literal: true

class ChangeStoryTypeClientTagsToStoryTypeClientPublicationTags < ActiveRecord::Migration[6.0]
  def change
    rename_table :story_type_client_tags, :story_type_client_publication_tags
  end
end
