# frozen_string_literal: true

class AddTeamWorkToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :team_work, :string, after: :done_at
  end
end
