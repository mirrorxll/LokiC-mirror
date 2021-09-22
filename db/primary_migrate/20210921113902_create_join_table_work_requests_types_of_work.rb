# frozen_string_literal: true

class CreateJoinTableWorkRequestsTypesOfWork < ActiveRecord::Migration[6.0]
  def change
    create_table :types_of_work_work_requests, id: false do |t|
      t.bigint :work_request_id
      t.bigint :type_of_work_id
      t.index %i[work_request_id type_of_work_id], unique: true, name: 'index_on_work_request_and_type_of_work'
      t.index %i[type_of_work_id work_request_id], unique: true, name: 'index_on_type_of_work_and_work_request'
    end
  end
end
