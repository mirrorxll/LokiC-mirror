# frozen_string_literal: true

class ChangeSampleTxtPartInAutoFeedbackConfirmations < ActiveRecord::Migration[6.0]
  def change
    change_column :auto_feedback_confirmations, :sample_txt_part, :string, limit: 6_000
  end
end
