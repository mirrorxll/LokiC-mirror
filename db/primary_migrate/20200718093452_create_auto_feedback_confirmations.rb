# frozen_string_literal: true

class CreateAutoFeedbackConfirmations < ActiveRecord::Migration[6.0]
  def change
    create_table :auto_feedback_confirmations do |t|
      t.belongs_to :iteration
      t.belongs_to :auto_feedback
      t.belongs_to :sample

      t.boolean    :confirmed, default: false
      t.string     :sample_part
      t.string     :sample_txt_part, limit: 2_000
      t.timestamps
    end

    add_index :auto_feedback_confirmations, %i[iteration_id auto_feedback_id],
              name: 'uniq_index_auto_feedback_confirmations', unique: true
  end
end
