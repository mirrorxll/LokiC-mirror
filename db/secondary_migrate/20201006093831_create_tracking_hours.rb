# frozen_string_literal: true

class CreateTrackingHours < ActiveRecord::Migration[6.0]
  def change
    create_table :tracking_hours do |t|
      t.belongs_to :developer
      t.belongs_to :type_of_work
      t.belongs_to :client
      t.belongs_to :week

      t.decimal  :hours, scale: 2, precision: 4

      t.date     :date
      t.string   :comment, limit: 2_000
    end
  end
end
