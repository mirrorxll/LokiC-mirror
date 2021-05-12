# frozen_string_literal: true

class CreatePostExportReports < ActiveRecord::Migration[6.0]
  def change
    create_table :post_export_feedbacks do |t|
      t.belongs_to :iteration
      t.belongs_to :submitter

      t.string :report_type, index: true
      t.json   :answers
      t.timestamps
    end
  end
end
