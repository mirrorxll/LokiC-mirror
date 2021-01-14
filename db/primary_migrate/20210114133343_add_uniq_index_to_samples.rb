# frozen_string_literal: true

class AddUniqIndexToSamples < ActiveRecord::Migration[6.0]
  def change
    add_index :samples,
              %i[story_type_id iteration_id client_id publication_id staging_row_id],
              name: 'uniq_story_type_sample',
              unique: true
  end
end
