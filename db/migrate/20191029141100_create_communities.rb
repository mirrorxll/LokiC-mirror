# frozen_string_literal: true

class CreateCommunities < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :communities do |t|
      t.integer :pipeline_index
      t.string  :name

      t.belongs_to :client

      t.timestamps
    end
  end
end
