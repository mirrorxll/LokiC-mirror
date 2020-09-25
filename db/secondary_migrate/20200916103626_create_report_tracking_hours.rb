# frozen_string_literal: true

class CreateReportTrackingHours < ActiveRecord::Migration[6.0]
  def change
    create_table :report_tracking_hours do |t|
      t.belongs_to :account

      t.decimal  :hours, scale: 2
      t.string   :type_of_work
      t.string   :client
      t.datetime :date
      t.string   :comment, limit: 2_000
    end
  end
end
