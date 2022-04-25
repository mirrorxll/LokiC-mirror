# frozen_string_literal: true

class CreateOpportunitiesRevenueTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :opportunities_revenue_types do |t|
      t.string     :opportunity_id, limit: 36
      t.belongs_to :revenue_type
      t.timestamps
    end

    add_index :opportunities_revenue_types, %i[opportunity_id revenue_type_id], name: 'index_on_o__rvt'
    add_index :opportunities_revenue_types, %i[revenue_type_id opportunity_id], name: 'index_on_rvt__o'
  end
end
