# frozen_string_literal: true

class CreateJoinTableWorkRequestsClients < ActiveRecord::Migration[6.0]
  def change
    create_join_table :work_requests, :clients do |t|
      t.index %i[work_request_id client_id], unique: true, name: 'index_on_work_request_and_client'
      t.index %i[client_id work_request_id], unique: true, name: 'index_on_client_and_work_request'
    end
  end
end
