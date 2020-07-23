# frozen_string_literal: true

class CreateFeedbackConfirmations < ActiveRecord::Migration[6.0]
  def change
    create_table :feedback_confirmations do |t|
      t.belongs_to :iteration
      t.belongs_to :feedback

      t.boolean    :confirmed, default: false
      t.timestamps
    end

    add_index :feedback_confirmations, %i[iteration_id feedback_id], unique: true
  end
end
