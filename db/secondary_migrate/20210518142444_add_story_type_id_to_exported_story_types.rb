# frozen_string_literal: true

class AddStoryTypeIdToExportedStoryTypes < ActiveRecord::Migration[6.0]
  def change

    # add_column :exported_story_types, :story_type_id, :integer,
    #            limit: 8, after: :developer_id
    # add_index :exported_story_types, :story_type_id

    # ExportedStoryType.all.each { |est| est.update(story_type: est.iteration.story_type) }
  end
end
