# frozen_string_literal: true

class AddRevisionedToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :revisioned, :boolean, after: :revision
  end
end
