# frozen_string_literal: true

class AddStatusIdToWorkRequests < ActiveRecord::Migration[6.0]
  def up
    change_table :work_requests do |t|
      t.belongs_to :status, after: :requester_id
    end

    status = Status.find_by(name: 'created and in queue')
    WorkRequest.all.each do |wr|
      wr.create_status_comment(subtype: 'status comment')
      wr.update(status: status)
    end
  end

  def down
    remove_column :work_requests, :status_id
  end
end
