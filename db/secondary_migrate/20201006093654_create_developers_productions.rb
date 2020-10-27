# frozen_string_literal: true

class CreateDevelopersProductions < ActiveRecord::Migration[6.0]
  def change
    create_table :exported_story_types do |t|
      t.belongs_to :developer
      t.belongs_to :iteration
      t.belongs_to :week

      t.boolean  :first_export
      t.date     :date_export
      t.integer  :count_samples
    end
  end
end
