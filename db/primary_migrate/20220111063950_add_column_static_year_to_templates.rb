# frozen_string_literal: true

class AddColumnStaticYearToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :static_year, :string, after: :body
  end
end
