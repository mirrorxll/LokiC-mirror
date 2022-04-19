# frozen_string_literal: true

class CreateJoinTableFactoidRequestsDataSets < ActiveRecord::Migration[6.0]
  def change
    create_join_table :factoid_requests, :data_sets do |t|
      t.index %i[factoid_request_id data_set_id], name: 'index_on_f_req_id__d_set_id', unique: true
      t.index %i[data_set_id factoid_request_id], name: 'index_on_d_set_id__f_req_id', unique: true
    end
  end
end
