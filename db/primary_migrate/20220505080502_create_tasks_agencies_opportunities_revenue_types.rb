# frozen_string_literal: true

class CreateTasksAgenciesOpportunitiesRevenueTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks_agencies_opportunities_rv_ts do |t|
      t.belongs_to :task
      t.belongs_to :agency
      t.belongs_to :opportunity
      t.belongs_to :revenue_type

      t.decimal    :percents, scale: 2, precision: 5

      t.index %i[task_id agency_id opportunity_id revenue_type_id],
              unique: true, name: 'tasks_ag_opp_rv_t_unique_index'
    end
  end
end
