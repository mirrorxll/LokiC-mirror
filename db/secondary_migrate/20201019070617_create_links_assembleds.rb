# frozen_string_literal: true

class CreateLinkAssembleds < ActiveRecord::Migration[6.0]
  def change
    create_table :links_assembleds do |t|
      t.belongs_to :week
      t.string :link
    end
  end
end
