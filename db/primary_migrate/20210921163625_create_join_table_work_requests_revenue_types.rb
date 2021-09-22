# frozen_string_literal: true

class CreateJoinTableWorkRequestsRevenueTypes < ActiveRecord::Migration[6.0]
  def change
    create_join_table :work_requests, :revenue_types do |t|
      t.index %i[work_request_id revenue_type_id], unique: true, name: 'index_on_work_request_and_revenue_type'
      t.index %i[revenue_type_id work_request_id], unique: true, name: 'index_on_revenue_type_and_work_request'
    end
  end
end
