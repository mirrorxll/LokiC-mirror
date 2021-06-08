# frozen_string_literal: true

class AddStatewideToPublications < ActiveRecord::Migration[6.0]
  def change
    add_column :publications, :statewide, :boolean, after: :home_page
  end
end
