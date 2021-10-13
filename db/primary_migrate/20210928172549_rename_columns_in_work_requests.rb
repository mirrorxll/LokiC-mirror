# frozen_string_literal: true

class RenameColumnsInWorkRequests < ActiveRecord::Migration[6.0]
  def change
    rename_column :work_requests, :expected_first_invoice, :first_invoice
    rename_column :work_requests, :expected_final_invoice, :final_invoice
  end
end
