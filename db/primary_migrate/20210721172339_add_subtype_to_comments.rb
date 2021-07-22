# frozen_string_literal: true

class AddSubtypeToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :subtype, :string, after: :commentable_type
  end
end
