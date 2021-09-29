# frozen_string_literal: true

class AddWorkRequestIdToTasks < ActiveRecord::Migration[6.0]
  def change
    change_table :tasks do |t|
      t.belongs_to :work_request, after: :id
    end
  end
end
