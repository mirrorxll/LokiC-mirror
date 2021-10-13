# frozen_string_literal: true

class AddEtaToWorkRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :work_requests, :eta, :date, after: :final_deadline
  end
end
