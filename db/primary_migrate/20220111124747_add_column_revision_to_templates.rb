# frozen_string_literal: true

class AddColumnRevisionToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :revision, :date, after: :static_year
  end
end
