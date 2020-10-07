# frozen_string_literal: true

class CreateExportedStoryTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :exported_story_types do |t|
      t.belongs_to :developer
      t.belongs_to :iteration

      t.boolean :first_export
      t.datetime :date_export
    end
  end
end
