# frozen_string_literal: true

class RenameTasksToMultiTasks < ActiveRecord::Migration[6.0]
  def change
    # rename_table :task_assignments, :multi_task_assignments
    # rename_table :task_checklists, :multi_task_checklists
    # rename_table :task_notes, :multi_task_notes
    # rename_table :task_reminder_frequencies, :multi_task_reminder_frequencies
    # rename_table :task_team_works, :multi_task_team_works
    # rename_table :tasks, :multi_tasks
    #
    #
    # remove_index :tasks_agencies_opportunities_rv_ts, :multi_task_id
    # remove_index :tasks_agencies_opportunities_rv_ts, :agency_id
    # remove_index :tasks_agencies_opportunities_rv_ts, :opportunity_id
    # remove_index :tasks_agencies_opportunities_rv_ts, :revenue_type_id

    rename_table :tasks_agencies_opportunities_rv_ts, :multi_task_agency_opportunity_revenue_types

    add_index :multi_task_agency_opportunity_revenue_types, :revenue_type_id, name: 'index_on_multi_task_id'
    add_index :multi_task_agency_opportunity_revenue_types, :revenue_type_id, name: 'index_on_agency_id'
    add_index :multi_task_agency_opportunity_revenue_types, :revenue_type_id, name: 'index_on_opportunity_id'
    add_index :multi_task_agency_opportunity_revenue_types, :revenue_type_id, name: 'index_on_revenue_type_id'
  end
end
