# frozen_string_literal: true

class CreateOpportunitiesOpportunityTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :opportunities_opportunity_types, id: false do |t|
      t.string   :id, limit: 36, primary_key: true
      t.string   :opportunity_id, limit: 36
      t.string   :opportunity_type_id, limit: 36
      t.datetime :archived_at, index: true
      t.timestamps
    end

    add_index :opportunities_opportunity_types, %i[opportunity_id opportunity_type_id], name: 'index_on_o__ot'
    add_index :opportunities_opportunity_types, %i[opportunity_type_id opportunity_id], name: 'index_on_ot__o'
  end
end
