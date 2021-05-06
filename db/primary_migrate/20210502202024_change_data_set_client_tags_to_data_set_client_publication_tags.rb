# frozen_string_literal: true

class ChangeDataSetClientTagsToDataSetClientPublicationTags < ActiveRecord::Migration[6.0]
  def change
    rename_table :data_set_client_tags, :data_set_client_publication_tags
  end
end
