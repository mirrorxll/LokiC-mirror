# frozen_string_literal: true

class AddPublicationToDataSetClientPublicationTags < ActiveRecord::Migration[6.0]
  def change
    add_reference :data_set_client_publication_tags, :publication,
                  foreign_key: true,  after: :client_id
  end
end
