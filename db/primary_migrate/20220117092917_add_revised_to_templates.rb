# frozen_string_literal: true

class AddRevisedToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :revised, :boolean, after: :revision
  end
end
