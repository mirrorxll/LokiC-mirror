# frozen_string_literal: true

class RenameIterationInAutoFeedbackConfirmations < ActiveRecord::Migration[6.0]
  def change
    rename_column :auto_feedback_confirmations, :iteration_id, :story_type_iteration_id
  end
end
