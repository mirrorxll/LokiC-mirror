# frozen_string_literal: true

class AddColumnArchivedToWorkRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :work_requests, :archived, :boolean,
               default: false, after: :priority_id
  end
end
