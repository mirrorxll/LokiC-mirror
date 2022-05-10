# frozen_string_literal: true

class CreateMainOpportunitiesRevenueTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :main_opportunities_revenue_types do |t|
      t.bigint :main_opportunity_id
      t.bigint :revenue_type_id
    end

    add_index :main_opportunities_revenue_types, %i[main_opportunity_id revenue_type_id], name: 'index_on_mo_rt'
    add_index :main_opportunities_revenue_types, %i[revenue_type_id main_opportunity_id], name: 'index_on_rt_mo'
  end
end
