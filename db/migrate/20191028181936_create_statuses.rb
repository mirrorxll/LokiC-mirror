# frozen_string_literal: true

class CreateStatuses < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :statuses do |t|
      t.string :name
      t.timestamps
    end
  end
end
