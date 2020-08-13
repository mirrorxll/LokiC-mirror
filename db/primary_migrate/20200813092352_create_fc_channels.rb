# frozen_string_literal: true

class CreateFcChannels < ActiveRecord::Migration[6.0]
  def change
    create_table :fc_channels do |t|
      t.belongs_to :account

      t.string :name
      t.timestamps
    end
  end
end
