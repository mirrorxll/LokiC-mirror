# frozen_string_literal: true

module TaskReceiptsHelper
  def time_confirm(task_receipt)
    distance_of_time_in_words(task_receipt.updated_at - task_receipt.created_at)
  end
end
